import 'dart:math';

import 'package:optional/optional.dart';
import 'package:playback_interop/playback_interop.dart';

import '../playback/caf_queue.dart';

abstract class CommunicationChannel {
  static const _PAGINATE_WINDOW = 256;

  /*
   * Business methods
   */

  void sendTrackState(Optional<CafPlaybackQueue> queue, TrackState state) {
    if (queue.isPresent && queue.value.currentTrack != null) {
      final dto = new TrackStateDto(
        trackState: state,
        trackIndex: queue.value.currentTrack.origQueueIndex,
        durationMs: queue.value.currentTrack.durationMs,
      );
      final msg = new CastMessage<TrackStateDto>(CafToSenderConstants.PB_TRACK, dto);
      sendMessage(msg);
    }
  }

  void sendQueue(Optional<CafPlaybackQueue> queue) {
    if (queue.isPresent && queue.value.currentTrack != null && queue.value.trackHolder != null) {
      // Paginate
      final tracks = queue.value.immutableTracks;
      int currIndex = 0;
      do {
        final sendList = tracks.sublist(currIndex, min(tracks.length, currIndex + _PAGINATE_WINDOW));
        final dto = new PlaybackQueueDto(
          currentTrack: null,
          trackHolder: null,
          immutableTracks: sendList,
          prioTracks: null,
          name: null,
          hash: queue.value.hash,
        );
        currIndex += _PAGINATE_WINDOW;
        final msg = new CastMessage<PlaybackQueueDto>(CafToSenderConstants.PB_QUEUE, dto);
        sendMessage(msg);
      } while (currIndex < tracks.length);

      final dto = new PlaybackQueueDto(
        currentTrack: queue.value.currentTrack,
        trackHolder: queue.value.trackHolder,
        immutableTracks: [],
        prioTracks: queue.value.prioTracks,
        name: queue.value.name,
        hash: queue.value.hash,
      );
      final msg = new CastMessage<PlaybackQueueDto>(CafToSenderConstants.PB_QUEUE, dto);
      sendMessage(msg);
    }
  }

  void sendShuffleState(Optional<CafPlaybackQueue> queue) {
    queue.ifPresent((queue) {
      final dto = queue.shuffleState;
      final msg = new CastMessage<ShuffleStateDto>(CafToSenderConstants.PB_SHUFFLING, dto);
      sendMessage(msg);
    });
  }

  void sendAddPrioDelta(PlaybackTrack track, bool append) {
    final dto = new AddPrioDeltaDto(track, append);
    final msg = new CastMessage<AddPrioDeltaDto>(CafToSenderConstants.PB_DELTA_ADD, dto);
    sendMessage(msg);
  }

  void sendMovePrioDelta(bool startPrio, int startIndex, bool targetPrio, int targetIndex) {
    final dto = new MovePrioDeltaDto(startPrio, startIndex, targetPrio, targetIndex);
    final msg = new CastMessage<MovePrioDeltaDto>(CafToSenderConstants.PB_DELTA_MOVE, dto);
    sendMessage(msg);
  }

  void sendRepeating(Optional<CafPlaybackQueue> queue) {
    queue.ifPresent((queue) {
      final dto = new RepeatingDto(queue.isRepeating);
      final msg = new CastMessage<RepeatingDto>(CafToSenderConstants.PB_REPEATING, dto);
      sendMessage(msg);
    });
  }

  void sendPlayerState(PlayerState playerState) {
    final dto = new PlayerStateDto(playerState);
    final msg = new CastMessage<PlayerStateDto>(CafToSenderConstants.PB_STATE_CHANGED, dto);
    sendMessage(msg);
  }

  void sendReady(bool isReady) {
    final dto = new ReadyDto(isReady);
    final msg = new CastMessage<ReadyDto>(CafToSenderConstants.PB_READY, dto);
    sendMessage(msg);
  }

  void sendSeek(int seekMs) {
    final dto = new SeekDto(seekMs);
    final msg = new CastMessage<SeekDto>(CafToSenderConstants.PB_SEEK, dto);
    sendMessage(msg);
  }

  void sendError(String error) {
    final dto = ErrorDto(new PlayerError(error));
    final msg = new CastMessage<ErrorDto>(CafToSenderConstants.PB_ERROR, dto);
    sendMessage(msg);
  }

  /*
   * Helper
   */

  void sendMessage(CastMessage<Dto> msg) {
    throw new UnsupportedError('Need to be overridden');
  }
}
