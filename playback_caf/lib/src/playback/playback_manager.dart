import 'package:optional/optional.dart';
import 'package:playback_interop/playback_interop.dart';

import '../io/communication_channel.dart';
import 'caf_queue.dart';
import 'player.dart';
import 'ui_manager.dart';

class PlaybackManager {
  final UiManager _uiManager;
  final CommunicationChannel _playerBridge;
  final _queueBuffer = <PlaybackTrack>[];
  bool _isBuildingQueue = false;

  PlayerState _playerState = PlayerState.ENDED;

  // lateint variables
  Optional<PlaybackPlayer> _player = const Optional.empty();
  Optional<CafPlaybackQueue> _queue = const Optional.empty();

  PlaybackManager(this._playerBridge, this._uiManager) : assert(_playerBridge != null && _uiManager != null);

  /*
   * CAF only methdos
   */

  void _setKillTimeout() {
    // TODO(me): Kill application
  }

  /*
   * Business methods
   */

  void startNewQueue() {
    if (!_isBuildingQueue) {
      _isBuildingQueue = true;
      _queueBuffer.clear();
    }
  }

  void appendToQueue(List<PlaybackTrack> tracks) {
    if (tracks.isNotEmpty) {
      _queueBuffer.addAll(tracks);
    } else {
      _queue = Optional.of(new CafPlaybackQueue.withQueue(_queue, _queueBuffer));
      _isBuildingQueue = false;

      final firstTrack = _queue.value.currentTrack;
      assert(firstTrack != null);
      _player.ifPresent((player) {
        // Kickoff first track
        player.playTrack(firstTrack);
        _playerState = PlayerState.BUFFERING;
        _broadcastQueue();
        _broadcastShuffleState();
        _uiManager.showPlayer(true);
      });
    }
  }

  void play() => _player.ifPresent((player) {
        _broadcastSeekMs(player.getTimeInMs());
        player.play();
      });

  void pause() => _player.ifPresent((player) {
        _broadcastSeekMs(player.getTimeInMs());
        player.pause();
      });

  void playNext() {
    if (_queue.isPresent && _player.isPresent) {
      final nextTrack = _queue.value.nextTrack();
      if (nextTrack != null) {
        _broadcastTrackState(TrackState.NEXT);
        _player.value.playTrack(nextTrack);
        final toPrefetch = _queue.value.peekNext();
        if (toPrefetch != null) {
          _player.value.cacheVideoKey(toPrefetch);
        }
      } else {
        // Broadcast end of playlist
        _queue = const Optional.empty();
        _playerState = PlayerState.ENDED;
        _broadcastPlayerState();
        _setKillTimeout();
        _player.value.stop();
        _uiManager.showPlayer(false);
      }
    } else {
      print('[WARNING] coulnd\'t play next track');
    }
  }

  void playPrevious() {
    if (_queue.isPresent && _player.isPresent) {
      final prevTrack = _queue.value.previousTrack();
      if (prevTrack != null) {
        _broadcastTrackState(TrackState.PREVIOUS);
        _player.value.playTrack(prevTrack);
      }
    } else {
      print('[WARNING] coulnd\'t play previous track');
    }
  }

  void playTrack(PlaybackTrack track) {
    _player.ifPresent((player) {
      if (!_queue.isPresent) {
        // Assert queue present
        _queue = new Optional.of(new CafPlaybackQueue.empty());
        _broadcastQueue();
      }

      // Add to prio list and play song
      try {
        _queue.value.addPrioTrack(track, false);
        _broadcastAddPrioDelta(track, false);
        playNext();
      } catch (e) {
        print("[ERROR] Coulnd't play track: $track - $e");
      }
    });
  }

  void stop() {
    _player.ifPresent((player) {
      player.stop();
      _playerState = PlayerState.ENDED;
      _broadcastPlayerState();
      _uiManager.showPlayer(false);
    });
  }

  void setSeek(int seekMs) {
    _player.ifPresent((player) {
      if (_playerState != PlayerState.PAUSED) {
        // Will break pause and seek callbacks otherwise
        _playerState = PlayerState.SEEKING;
      } else {
        _broadcastSeekMs(seekMs);
      }
      player.seekTo(seekMs); // Internal state will be buffering
    });
  }

  void setShuffling(bool isShuffling, [int shuffleSeed = 0]) {
    _queue.ifPresent((queue) {
      try {
        queue.setShuffling(isShuffling, shuffleSeed);
        _broadcastShuffleState();
      } catch (e) {
        print('[ERROR] Couldn\'t shuffle: $e');
      }
    });
  }

  void setRepeating(bool isRepeating) {
    _queue.ifPresent((queue) {
      queue.setRepeating(isRepeating);
      _broadcastRepeatState();
    });
  }

  void appendToPrio(PlaybackTrack track) {
    _queue.ifPresent((queue) {
      try {
        queue.addPrioTrack(track, true);
        _broadcastAddPrioDelta(track, true);
      } catch (e) {
        print('[ERROR] Coulndn\t append $e');
      }
    });
  }

  void move(bool startPrio, int startIndex, bool targetPrio, int targetIndex) {
    _queue.ifPresent((queue) {
      try {
        queue.move(startPrio, startIndex, targetPrio, targetIndex);
        _broadcastMovePrioDelta(startPrio, startIndex, targetPrio, targetIndex);
      } catch (e) {
        print('[ERROR] Couldn\'t move track: $e');
      }
    });
  }

  /*
   * Player callbacks
   */

  void onTrackSeek(int seekMs) {
    if (_playerState == PlayerState.SEEKING) {
      // Notify we are no longer buffering
      _playerState = PlayerState.PLAYING;
      _broadcastPlayerState();
    }
    _broadcastSeekMs(seekMs);
  }

  void onPlayerReady(PlaybackPlayer player) {
    if (!_player.isPresent) {
      _player = new Optional.of(player);
      _broadcastReady();
      _uiManager.showReady();
    }
  }

  void onError(String error) {
    assert(error != null);
    _broadcastError(error);
  }

  void onPlayerStateChanged(PlayerState state) {
    assert(_player.isPresent);
    final player = _player.value;

    switch (state) {
      case PlayerState.PLAYING:
        if (_playerState != PlayerState.SEEKING) {
          _broadcastTrackState(TrackState.SYNC);
        }
        _broadcastSeekMs(player.getTimeInMs());
        _playerState = state;
        break;
      case PlayerState.ENDED:
        playNext(); // State is set here
        break;
      case PlayerState.PAUSED:
        if (_playerState != PlayerState.BUFFERING) {
          _setKillTimeout();
          _broadcastSeekMs(player.getTimeInMs());
        }
        _playerState = state;
        break;
      case PlayerState.SEEKING:
      case PlayerState.BUFFERING:
        _playerState = state;
        break;
      default:
        throw StateError('Invalid State: $state');
    }

    _broadcastPlayerState();
  }

  /*
   * Sync contract
   */

  void syncAll() {
    _broadcastReady();
    _broadcastQueue();
    _broadcastTrackState(TrackState.SYNC);
    _broadcastPlayerState();
    _broadcastRepeatState();
    _broadcastShuffleState();
  }

  /*
   * broadcast helpers
   */

  void _broadcastTrackState(TrackState state) => _playerBridge.sendTrackState(_queue, state);

  void _broadcastQueue() => _playerBridge.sendQueue(_queue);

  void _broadcastReady() => _playerBridge.sendReady(_player.isPresent);

  void _broadcastPlayerState() => _playerBridge.sendPlayerState(_playerState);

  void _broadcastShuffleState() => _playerBridge.sendShuffleState(_queue);

  void _broadcastRepeatState() => _playerBridge.sendRepeating(_queue);

  void _broadcastAddPrioDelta(PlaybackTrack track, bool append) => _playerBridge.sendAddPrioDelta(track, append);

  void _broadcastMovePrioDelta(bool startPrio, int startIndex, bool targetPrio, int targetIndex) =>
      _playerBridge.sendMovePrioDelta(startPrio, startIndex, targetPrio, targetIndex);

  void _broadcastSeekMs(int seekMs) => _playerBridge.sendSeek(seekMs);

  void _broadcastError(String error) => _playerBridge.sendError(error);

  /*
   * Whitebox test
   */

  // ignore: non_constant_identifier_names
  CafPlaybackQueue get TEST_queue => _queue.value;
}
