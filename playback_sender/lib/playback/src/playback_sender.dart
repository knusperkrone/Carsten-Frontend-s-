import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:playback_interop/playback_interop.dart';

import 'ipc/cast_playback_context.dart';

class PlaybackSender {
  static const _PAGINATE_WINDOW = 256;
  static const _TIMER_DURATION = Duration(milliseconds: 125);

  Timer _nextTimeout = new Timer(const Duration(), () {});
  Timer _prevTimeout = new Timer(const Duration(), () {});
  final CastPlaybackContext _context;

  bool isBackground = false;

  PlaybackSender(this._context);

  /*
   * Getters/setters
   */

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  @protected
  set isConnected(bool val) => _isConnected = val;

  /*
   * Business methods
   */

  Future<void> sendTracks(
      List<PlaybackTrack> tracks, int selected, String playlistName) async {
    tracks.insert(0, PlaybackTrack.dtoHack(selected, playlistName));

    _sendMsg(SenderToCafConstants.PB_CLEAR_QUEUE); // Clear current queue

    int currIndex = 0;
    do {
      // paginate
      final sendList = tracks.sublist(
          currIndex, min(tracks.length, currIndex + _PAGINATE_WINDOW));
      currIndex += _PAGINATE_WINDOW;
      await _sendMsg(SenderToCafConstants.PB_APPEND_TO_QUEUE, sendList);
    } while (currIndex < tracks.length);

    // Notify last msg
    await _sendMsg(SenderToCafConstants.PB_APPEND_TO_QUEUE, <PlaybackTrack>[]);
  }

  /*
   * stubs
   */

  Future<void> sendPlay() async => await _sendMsg(SenderToCafConstants.PB_PLAY);

  Future<void> sendPause() async =>
      await _sendMsg(SenderToCafConstants.PB_PAUSE);

  Future<void> sendPlayTrack(PlaybackTrack track) async =>
      await _sendMsg(SenderToCafConstants.PB_PLAY_TRACK, track);

  void sendStop() => _sendMsg(SenderToCafConstants.PB_STOP);

  Future<void> sendNext() async {
    if (!_nextTimeout.isActive) {
      await _sendMsg(SenderToCafConstants.PB_NEXT_TRACK);
    }
    _nextTimeout = _createTimeout();
  }

  Future<void> sendPrevious() async {
    if (!_prevTimeout.isActive) {
      await _sendMsg(SenderToCafConstants.PB_PREV_TRACK);
    }
    _prevTimeout = _createTimeout();
  }

  Future<void> sendShuffling(bool isShuffling) async =>
      await _sendMsg(SenderToCafConstants.PB_SHUFFLING, isShuffling);

  Future<void> sendRepeating(bool isRepeating) async =>
      await _sendMsg(SenderToCafConstants.PB_REPEATING, isRepeating);

  Future<void> sendSeek(int seekMs) async =>
      await _sendMsg(SenderToCafConstants.PB_SEEK_TO, seekMs);

  Future<void> scheduleFullSync() async {
    if (isBackground) {
      await _sendMsg(SenderToCafConstants.PB_SCHEDULE_SYNC);
    }
  }

  Future<void> sendAddToPrio(PlaybackTrack track) =>
      _sendMsg(SenderToCafConstants.PB_APPEND_TO_PRIO, track);

  Future<void> sendMove(bool startPrio, int startIndex, bool targetPrio,
          int targetIndex) async =>
      await _sendMsg(SenderToCafConstants.PB_MOVE,
          [startPrio, startIndex, targetPrio, targetIndex]);

  /*
   * Helpers
   */

  Timer _createTimeout() => new Timer(_TIMER_DURATION, () {});

  Future<void> _sendMsg(String type, [dynamic payload = '']) async {
    final msg = new CastMessage<dynamic>(type, payload);
    await _context.send(msg);
  }
}
