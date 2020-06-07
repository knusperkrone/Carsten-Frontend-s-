import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playback_interop/playback_interop.dart';

import 'ipc/cast_playback_context.dart';

class PlaybackSender {
  static const _PAGINATE_WINDOW = 1024;
  static const _TIMER_DURATION = Duration(milliseconds: 125);

  Timer _nextTimeout = new Timer(const Duration(), () {});
  Timer _prevTimeout = new Timer(const Duration(), () {});
  final CastPlaybackContext _context;
  bool isBackground = false;

  PlaybackSender(this._context);

  /*
   * Getters?setters
   */

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  @protected
  set isConnected(bool val) => _isConnected = val;

  /*
   * Business methods
   */

  void sendTracks(
      List<PlaybackTrack> tracks, int selected, String playlistName) {
    tracks.insert(0, PlaybackTrack.dtoHack(selected, playlistName));

    _sendMsg(SenderToCafConstants.PB_CLEAR_QUEUE); // Clear current queue

    int currIndex = 0;
    do {
      // paginate
      final sendList = tracks.sublist(
          currIndex, min(tracks.length, currIndex + _PAGINATE_WINDOW));
      currIndex += _PAGINATE_WINDOW;
      _sendMsg(SenderToCafConstants.PB_APPEND_TO_QUEUE, sendList);
    } while (currIndex < tracks.length);

    // Notify last msg
    _sendMsg(SenderToCafConstants.PB_APPEND_TO_QUEUE, <PlaybackTrack>[]);
  }

  /*
   * stubs
   */

  void sendPlay() => _sendMsg(SenderToCafConstants.PB_PLAY);

  void sendPause() => _sendMsg(SenderToCafConstants.PB_PAUSE);

  void sendPlayTrack(PlaybackTrack track) =>
      _sendMsg(SenderToCafConstants.PB_PLAY_TRACK, track);

  void sendStop() => _sendMsg(SenderToCafConstants.PB_STOP);

  void sendNext() {
    if (!_nextTimeout.isActive) {
      _sendMsg(SenderToCafConstants.PB_NEXT_TRACK);
    }
    _nextTimeout = _createTimer();
  }

  void sendPrevious() {
    if (!_prevTimeout.isActive) {
      _sendMsg(SenderToCafConstants.PB_PREV_TRACK);
    }
    _prevTimeout = _createTimer();
  }

  void sendShuffling(bool isShuffling) =>
      _sendMsg(SenderToCafConstants.PB_SHUFFLING, isShuffling);

  void sendRepeating(bool isRepeating) =>
      _sendMsg(SenderToCafConstants.PB_REPEATING, isRepeating);

  void sendSeek(int seekMs) =>
      _sendMsg(SenderToCafConstants.PB_SEEK_TO, seekMs);

  void scheduleFullSync() {
    if (isBackground) {
      _sendMsg(SenderToCafConstants.PB_SCHEDULE_SYNC);
    }
  }

  void sendAddToPrio(PlaybackTrack track) =>
      _sendMsg(SenderToCafConstants.PB_APPEND_TO_PRIO, track);

  void sendMove(
          bool startPrio, int startIndex, bool targetPrio, int targetIndex) =>
      _sendMsg(SenderToCafConstants.PB_MOVE,
          [startPrio, startIndex, targetPrio, targetIndex]);

  /*
   * Helpers
   */

  Timer _createTimer() => new Timer(_TIMER_DURATION, () {});

  void _sendMsg(String type, [dynamic payload = '']) {
    final msg = new CastMessage<dynamic>(type, payload);
    _context.send(msg);
  }
}
