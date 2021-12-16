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
  PlaybackPlayer? _player;
  CafPlaybackQueue? _queue;

  PlaybackManager(this._playerBridge, this._uiManager);

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
    print('[DEBUG] Start new queue');
    if (!_isBuildingQueue) {
      _isBuildingQueue = true;
      _queueBuffer.clear();
    }
  }

  void appendToQueue(List<PlaybackTrack> tracks) {
    print('[DEBUG] append to queue');
    if (tracks.isNotEmpty) {
      _queueBuffer.addAll(tracks);
    } else {
      print('[DEBUG] New queue and play track $_player');
      _queue = new CafPlaybackQueue.withQueue(_queue, _queueBuffer);
      _isBuildingQueue = false;

      final firstTrack = _queue!.currentTrack!;
      if (_player != null) {
        // Kickoff first track
        _player!.playTrack(firstTrack);
        _playerState = PlayerState.BUFFERING;
        _broadcastQueue();
        _broadcastShuffleState();
        _uiManager.showPlayer(true);
      }
    }
  }

  void play() {
    if (_player != null) {
      _broadcastSeekMs(_player!.getTimeInMs());
      _player!.play();
    }
  }

  void pause() {
    if (_player != null) {
      _broadcastSeekMs(_player!.getTimeInMs());
      _player!.pause();
    }
  }

  void playNext() {
    if (_queue == null || _player == null) {
      print('[WARNING] coulnd\'t play next track');
      return;
    }

    final nextTrack = _queue!.nextTrack();
    if (nextTrack != null) {
      _broadcastTrackState(TrackState.NEXT);
      _player!.playTrack(nextTrack);
      final toPrefetch = _queue!.peekNext();
      if (toPrefetch != null) {
        _player!.cacheVideoKey(toPrefetch);
      }
    } else {
      // Broadcast end of playlist
      _queue = null;
      _playerState = PlayerState.ENDED;
      _broadcastPlayerState();
      _setKillTimeout();
      _player!.stop();
      _uiManager.showPlayer(false);
    }
  }

  void playPrevious() {
    if (_queue != null && _player != null) {
      final prevTrack = _queue!.previousTrack();
      if (prevTrack != null) {
        _broadcastTrackState(TrackState.PREVIOUS);
        _player!.playTrack(prevTrack);
      }
    } else {
      print('[WARNING] coulnd\'t play previous track');
    }
  }

  void playTrack(PlaybackTrack track) {
    if (_player != null) {
      if (_queue == null) {
        // Assert queue present
        _queue = new CafPlaybackQueue.empty();
        _broadcastQueue();
      }

      // Add to prio list and play song
      try {
        _queue!.addPrioTrack(track, false);
        _broadcastAddPrioDelta(track, false);
        playNext();
      } catch (e) {
        print("[ERROR] Coulnd't play track: $track - $e");
      }
    }
  }

  void stop() {
    if (_player != null) {
      _player!.stop();
      _playerState = PlayerState.ENDED;
      _broadcastPlayerState();
      _uiManager.showPlayer(false);
    }
  }

  void setSeek(int seekMs) {
    if (_player != null) {
      if (_playerState != PlayerState.PAUSED) {
        // Will break pause and seek callbacks otherwise
        _playerState = PlayerState.SEEKING;
      } else {
        _broadcastSeekMs(seekMs);
      }
      _player!.seekTo(seekMs); // Internal state will be buffering
    }
  }

  void setShuffling(bool isShuffling, [int shuffleSeed = 0]) {
    if (_queue != null) {
      try {
        _queue!.setShuffling(isShuffling, shuffleSeed);
        _broadcastShuffleState();
      } catch (e) {
        print('[ERROR] Couldn\'t shuffle: $e');
      }
    }
  }

  void setRepeating(bool isRepeating) {
    if (_queue != null) {
      _queue!.setRepeating(isRepeating);
      _broadcastRepeatState();
    }
  }

  void appendToPrio(PlaybackTrack track) {
    if (_queue != null) {
      try {
        _queue!.addPrioTrack(track, true);
        _broadcastAddPrioDelta(track, true);
      } catch (e) {
        print('[ERROR] Coulndn\t append $e');
      }
    }
  }

  void move(bool startPrio, int startIndex, bool targetPrio, int targetIndex) {
    if (_queue != null) {
      try {
        _queue!.move(startPrio, startIndex, targetPrio, targetIndex);
        _broadcastMovePrioDelta(startPrio, startIndex, targetPrio, targetIndex);
      } catch (e) {
        print('[ERROR] Couldn\'t move track: $e');
      }
    }
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
    _player = player;
    _broadcastReady();
    _uiManager.showReady();
  }

  void onError(String error) {
    _broadcastError(error);
    Future.delayed(const Duration(seconds: 2), playNext);
  }

  void onPlayerStateChanged(PlayerState state) {
    if (_player == null) {
      return;
    }

    final player = _player!;
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

  void _broadcastReady() => _playerBridge.sendReady(_player != null);

  void _broadcastPlayerState() => _playerBridge.sendPlayerState(_playerState);

  void _broadcastShuffleState() => _playerBridge.sendShuffleState(_queue);

  void _broadcastRepeatState() => _playerBridge.sendRepeating(_queue);

  void _broadcastAddPrioDelta(PlaybackTrack track, bool append) => _playerBridge.sendAddPrioDelta(track, append);

  void _broadcastMovePrioDelta(bool startPrio, int startIndex, bool targetPrio, int targetIndex) =>
      _playerBridge.sendMovePrioDelta(startPrio, startIndex, targetPrio, targetIndex);

  void _broadcastSeekMs(int? seekMs) => _playerBridge.sendSeek(seekMs);

  void _broadcastError(String error) => _playerBridge.sendError(error);

  /*
   * Whitebox test
   */

  // ignore: non_constant_identifier_names
  CafPlaybackQueue get TEST_queue => _queue!;
}
