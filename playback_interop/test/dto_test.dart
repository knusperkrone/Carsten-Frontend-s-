import 'dart:convert';

import 'package:test/test.dart';
import 'package:playback_interop/playback_interop.dart';
import 'package:playback_interop/playback_interop_test.dart';

void main() {
  final _assertValidTrack = (PlaybackTrack resultTrack) {
    expect(resultTrack.origQueueIndex, expTrackOrigQueueIndex);
    expect(resultTrack.durationMs, expTrackDurationMs);
    expect(resultTrack.queueIndex, expTrackQueueIndex);
    expect(resultTrack.title, expTrackTitle);
    expect(resultTrack.artist, expTrackArtist);
    expect(resultTrack.album, expTrackAlbum);
    expect(resultTrack.coverUrl, expTrackCoverUrl);
  };

  group('Dto transformation', () {
    test('ReadDto', () {
      final dto = new ReadyDto.fromJson(jsonDecode(readyDtoJson) as Map<String, dynamic>);

      expect(expReady, dto.ready);
      expect(dto, new ReadyDto.fromJson(dto.toJson()));
    });

    test('RepeatingDto', () {
      final dto = new RepeatingDto.fromJson(jsonDecode(repeatingDtoJson) as Map<String, dynamic>);

      expect(expRepeatingDto, dto.isRepeating);
      final json = jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>;
      expect(dto, new RepeatingDto.fromJson(json));
    });

    test('SeekDto', () {
      final dto = new SeekDto.fromJson(jsonDecode(seekDtoJson) as Map<String, dynamic>);

      expect(expSeekDtoSeekMs, dto.seekMs);
      final json = jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>;
      expect(dto, new SeekDto.fromJson(json));
    });

    test('PlayerStateDto', () {
      final dto = new PlayerStateDto.fromJson(jsonDecode(playerStateDtoJson) as Map<String, dynamic>);

      expect(expPlayerStateDtoState, dto.state);
      final json = jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>;
      expect(dto, new PlayerStateDto.fromJson(json));
    });

    test('ErrorStateDto', () {
      final dto = new ErrorDto.fromJson(jsonDecode(errorStateDtoJson) as Map<String, dynamic>);

      expect(expErrorState, dto.error);
      final json = jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>;
      expect(dto, new ErrorDto.fromJson(json));
    });

    test('TrackStateDto', () {
      final dto = new TrackStateDto.fromJson(jsonDecode(trackStateDtoJson) as Map<String, dynamic>);

      expect(expTrackDtoState, dto.trackState);
      expect(expTrackDtoIndex, dto.trackIndex);
      final json = jsonDecode(jsonEncode(dto.toJson())) as Map<String, dynamic>;
      expect(dto, new TrackStateDto.fromJson(json));
    });

    test('ShuffleStateDto', () {
      final shuffleState = new ShuffleStateDto.fromJson(jsonDecode(shuffledJson) as Map<String, dynamic>);
      expect(shuffleState.isShuffled, expShuffleStateShuffled);
      expect(shuffleState.initSeed, expShuffleStateSeed);

      final startTrack = shuffleState.startTrack;
      _assertValidTrack(startTrack);
    });

    test('AddPrioDeltaDto', () {
      final addDelta = new AddPrioDeltaDto.fromJson(jsonDecode(addPrioJson) as Map<String, dynamic>);

      expect(addDelta.append, expAddPrioAppend);
      _assertValidTrack(addDelta.track);
    });

    test('MovDeltaDto', () {
      final movDelta = new MovePrioDeltaDto.fromJson(jsonDecode(movDeltaJson) as Map<String, dynamic>);

      expect(movDelta.startPrio, expMovStartPrio);
      expect(movDelta.startIndex, expMovStartIndex);
      expect(movDelta.targetPrio, expMovTargetPrio);
      expect(movDelta.targetIndex, expMovTargetIndex);
    });
  });

  test('PlaybackTrack', () {
    final track = new PlaybackTrack.fromJson(jsonDecode(trackJson) as Map<String, dynamic>);
    _assertValidTrack(track);

    expect(track, new PlaybackTrack.fromJson(track.toJson()));
  });

  test('PlaybackQueueDto', () {
    final queue = new PlaybackQueueDto.fromJson(jsonDecode(queueJson) as Map<String, dynamic>);
    expect(queue.hash, expQueueHash);
    _assertValidTrack(queue.currentTrack);
    expect(queue.immutableTracks.length, expQueueListLength);
    for (int i = 0; i < expQueueListLength; i++) {
      _assertValidTrack(queue.immutableTracks[i]);
    }

    final copySource = jsonEncode(queue.toJson());
    final copyQueue = new PlaybackQueueDto.fromJson(jsonDecode(copySource) as Map<String, dynamic>);
    expect(copyQueue.hash, expQueueHash);
    _assertValidTrack(copyQueue.currentTrack);
    expect(copyQueue.immutableTracks.length, expQueueListLength);
    for (int i = 0; i < expQueueListLength; i++) {
      _assertValidTrack(copyQueue.immutableTracks[i]);
    }
  });
}
