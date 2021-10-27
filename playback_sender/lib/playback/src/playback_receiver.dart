import 'dart:async';

import 'package:chrome_tube/playback/src/sender_playback_queue.dart';
import 'package:flutter/material.dart';
import 'package:playback_interop/playback_interop.dart';

import 'ipc/cast_playback_context.dart';
import 'playback_listeners.dart';
import 'playback_sender.dart';

class PlaybackReceiver extends PlaybackSender {
  /*
   * Singleton
   */

  static PlaybackReceiver? _instance;

  factory PlaybackReceiver() {
    _instance ??= PlaybackReceiver.internal(new CastPlaybackContext());
    return _instance!;
  }

  @protected
  PlaybackReceiver.internal(CastPlaybackContext cxt) : super(cxt);

  factory PlaybackReceiver.test(CastPlaybackContext mockedContext) {
    return PlaybackReceiver.internal(mockedContext);
  }

  /*
   * members
   */

  final _completer = new StreamController<PlaybackUIEvent>.broadcast();

  int _currSeek = 0;
  bool _isRepeating = false;
  SimplePlaybackState _currPlayerState = SimplePlaybackState.ENDED;
  DateTime _seekTimestamp = new DateTime.now();
  ShuffleStateDto? _currShuffleState;
  SenderPlaybackQueue? _queue;
  List<PlaybackTrack>? _trackBuffer;

  /*
   * public getter
   */

  Stream<PlaybackUIEvent> get stream => _completer.stream;

  double get trackSeek => _currSeek.toDouble();

  bool get isRepeating => _isRepeating;

  DateTime get seekTimestamp => _seekTimestamp;

  ShuffleStateDto? get currShuffleState => _currShuffleState;

  bool get isShuffled => _currShuffleState?.isShuffled ?? false;

  SimplePlaybackState get currPlayerState => _currPlayerState;

  PlaybackTrack? get track => _queue?.currentTrack;

  int get trackIndex => _queue?.trackHolder?.queueIndex ?? 0;

  List<PlaybackTrack> get prioTracks => _queue?.prioTracks ?? [];

  List<PlaybackTrack> get queueTracks => _queue?.mutableTracks ?? [];

  String get playlistName => _queue?.name ?? '';

  /*
   * protected getters/setters
   */

  @protected
  SenderPlaybackQueue? get queue => _queue;

  @protected
  set track(PlaybackTrack? val) => val;

  @protected
  set currPlayerState(SimplePlaybackState val) => _currPlayerState = val;

  @protected
  set isRepeating(bool val) => _isRepeating = val;

  @protected
  set seekTimestamp(DateTime val) => _seekTimestamp = val;

  @protected
  set shuffleState(ShuffleStateDto val) => _currShuffleState = val;

  @protected
  set queue(SenderPlaybackQueue? val) => _queue = val;

  @protected
  set trackSeek(double seek) => _currSeek = seek.toInt();

  /*
   * Receiver methods
   */

  void onConnect(ReadyDto readyDto) {
    isConnected = readyDto.ready;
    if (readyDto.ready == false) {
      _onStop();
    } else {
      _completer.add(PlaybackUIEvent.READY);
    }
  }

  void onPlayerState(PlayerStateDto playerStateDto) {
    switch (playerStateDto.state) {
      case PlayerState.SEEKING:
      case PlayerState.BUFFERING:
        _currPlayerState = SimplePlaybackState.BUFFERING;
        break;
      case PlayerState.ENDED:
        _currPlayerState = SimplePlaybackState.ENDED;
        _onStop(); // notify
        break;
      case PlayerState.PAUSED:
        _currPlayerState = SimplePlaybackState.PAUSED;
        break;
      case PlayerState.PLAYING:
        _currPlayerState = SimplePlaybackState.PLAYING;
        break;
      default:
        print('ERROR] invalid state ${playerStateDto.state}');
        return;
    }
    _completer.add(PlaybackUIEvent.PLAYER_STATE);
  }

  void onQueue(PlaybackQueueDto queueDto) {
    _trackBuffer ??= [];
    if (queueDto.immutableTracks.isNotEmpty) {
      _trackBuffer!.addAll(queueDto.immutableTracks);
    } else {
      _queue = new SenderPlaybackQueue.fromQueue(queueDto, _trackBuffer!,
          isRepeating, isShuffled, _currShuffleState?.initSeed);
      _trackBuffer = null;
      _completer.add(PlaybackUIEvent.QUEUE);
    }
  }

  void onTrackState(TrackStateDto trackStateDto) {
    if (_queue == null) {
      return;
    }

    switch (trackStateDto.trackState) {
      case TrackState.KICKOFF:
        break;
      case TrackState.NEXT:
        _queue!.nextTrack();
        _seekTimestamp = DateTime.now();
        _currSeek = 0;
        _completer.add(PlaybackUIEvent.SEEK);
        break;
      case TrackState.PREVIOUS:
        _queue!.previousTrack();
        _seekTimestamp = DateTime.now();
        _currSeek = 0;
        _completer.add(PlaybackUIEvent.SEEK);
        break;
      case TrackState.SYNC:
        if (trackStateDto.durationMs != null) {
          if (_queue!.currentTrack != null) {
            _queue!.currentTrack!.durationMs = trackStateDto.durationMs;
          }
        }
        break;
      default:
        print('[ERROR] invalid state ${trackStateDto.trackState}');
        return;
    }

    if (_queue!.currentTrack != null &&
        _queue!.currentTrack!.origQueueIndex != trackStateDto.trackIndex) {
      _reSync(
          'Invalid: ${_queue!.currentTrack?.origQueueIndex} != ${trackStateDto.trackIndex}');
    }

    _completer.add(PlaybackUIEvent.TRACK);
  }

  void onTrackSeek(SeekDto seekDto) {
    _seekTimestamp = DateTime.now();
    _currSeek = seekDto.seekMs;
    _completer.add(PlaybackUIEvent.SEEK);
  }

  void onShuffling(ShuffleStateDto shuffleDto) {
    if (queue == null) {
      return;
    }

    try {
      _queue!.setShuffleState(shuffleDto);
      _currShuffleState = shuffleDto;
      _completer.add(PlaybackUIEvent.QUEUE);
    } catch (e) {
      _reSync("Couldn't shuffle:\n$e");
    }
  }

  void onRepeating(RepeatingDto repeat) {
    _isRepeating = repeat.isRepeating;
    _completer.add(PlaybackUIEvent.REPEATING);
  }

  void onAddPrioDelta(AddPrioDeltaDto addDeltaDto) {
    if (queue == null) {
      return;
    }

    try {
      queue!.addPrioTrack(addDeltaDto.track, addDeltaDto.append);
      _completer.add(PlaybackUIEvent.QUEUE);
    } catch (e) {
      _reSync("Couldn't add $e");
    }
  }

  void onMovePrioDelta(MovePrioDeltaDto moveDeltaDto) {
    if (queue == null) {
      return;
    }

    try {
      queue!.move(moveDeltaDto.startPrio, moveDeltaDto.startIndex,
          moveDeltaDto.targetPrio, moveDeltaDto.targetIndex);
      _completer.add(PlaybackUIEvent.QUEUE);
    } catch (e) {
      _reSync("Couldn't move $e");
    }
  }

  void onError(ErrorDto errorDto) {
    print('On error:\n${errorDto.error}');
  }

/*
   * Helpers
   */

  void _reSync(String msg) {
    print('[ERROR] $msg');
    scheduleFullSync();
  }

  void _onStop() {
    _isRepeating = false;
    _currSeek = 0;
    _queue = null;

    _completer.add(PlaybackUIEvent.SEEK);
    _completer.add(PlaybackUIEvent.TRACK);
    _completer.add(PlaybackUIEvent.QUEUE);
    _completer.add(PlaybackUIEvent.REPEATING);
    _completer.add(PlaybackUIEvent.PLAYER_STATE);
  }
}
