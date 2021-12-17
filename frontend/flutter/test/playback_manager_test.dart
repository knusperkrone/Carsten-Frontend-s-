import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/playback/src/ipc/cast_playback_context.dart';
import 'package:chrome_tube/ui/common/state.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:playback_core/playback_core.dart';
import 'package:playback_core/playback_core_test.dart';

import 'playback_manager_test.mocks.dart';

@GenerateMocks([UIListener, CastPlaybackContext])
void main() {
  late UIListener listener;
  late PlaybackManager manager;

  setUp(() {
    listener = new MockUIListener();
    manager = new PlaybackManager.test(new MockCastPlaybackContext());
    manager.stream.listen(listener.onEvent);
  });

  PlaybackQueueDto _generateMockQueueDto() {
    final List<PlaybackTrack> mockedDtoTracks = generateTracks();
    final PlaybackTrack first = mockedDtoTracks[0];
    return new PlaybackQueueDto(
        currentTrack: first,
        trackHolder: first,
        prioTracks: <PlaybackTrack>[],
        immutableTracks: mockedDtoTracks,
        name: 'name',
        hash: 'hash');
  }

  PlaybackQueueDto _generateEndingQueueDto() {
    final PlaybackTrack first = generateTracks()[0];
    return new PlaybackQueueDto(
        currentTrack: first,
        trackHolder: first,
        prioTracks: <PlaybackTrack>[],
        immutableTracks: <PlaybackTrack>[],
        name: 'name',
        hash: 'hash');
  }

  test('Interop manager not shuffling', () async {
    // Prepare
    final mockedTracks = generateTracks();
    final PlaybackTrack expectedFirst = mockedTracks.first;
    final List<PlaybackTrack> expectedTail = mockedTracks;
    final PlaybackQueueDto mockedDtoQueue = _generateMockQueueDto();
    final PlaybackQueueDto endingDtoQueue = _generateEndingQueueDto();

    final mockedState = new ShuffleStateDto(expectedFirst, false, SHUFFLE_SEED);

    // Execute
    manager.onQueue(mockedDtoQueue);
    manager.onQueue(endingDtoQueue);
    manager.onShuffling(mockedState);

    // Verify
    const matcher = ListEquality<PlaybackTrack>();
    await Future.delayed(const Duration(milliseconds: 0), () {});
    verify(listener.onEvent(PlaybackUIEvent.QUEUE));

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track);
    expect(matcher.hash(expectedTail), matcher.hash(manager.queueTracks));
  });

  test('Interop manager shuffling', () async {
    // Prepare
    final mockedTracks = generateTracks();
    final PlaybackTrack expectedFirst = mockedTracks.first;
    final PlaybackQueueDto mockedDtoQueue = _generateMockQueueDto();
    final PlaybackQueueDto endingDtoQueue = _generateEndingQueueDto();

    final mockedState = new ShuffleStateDto(expectedFirst, true, SHUFFLE_SEED);

    // Execute
    manager.onQueue(mockedDtoQueue);
    manager.onQueue(endingDtoQueue);
    manager.onShuffling(mockedState);

    // Verify
    await Future.delayed(const Duration(milliseconds: 0), () {});
    verify(listener.onEvent(PlaybackUIEvent.QUEUE)).called(2);

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track);
    expect(EXPECTED_SHUFFLED_MANAGER, tracksToString(manager.queueTracks));
  });

  test('Interop manager on/off shuffling', () async {
    // Prepare
    final mockedTracks = generateTracks();
    final PlaybackTrack expectedFirst = mockedTracks.first;
    final PlaybackQueueDto mockedDtoQueue = _generateMockQueueDto();
    final PlaybackQueueDto endingDtoQueue = _generateEndingQueueDto();

    final mockedState = new ShuffleStateDto(expectedFirst, true, SHUFFLE_SEED);

    // Execute
    manager.onQueue(mockedDtoQueue);
    manager.onQueue(endingDtoQueue);
    manager.onShuffling(mockedState);
    manager.onQueue(mockedDtoQueue);
    manager.onQueue(endingDtoQueue);

    // Verify
    await Future.delayed(const Duration(milliseconds: 0), () {});
    verify(listener.onEvent(PlaybackUIEvent.QUEUE)).called(3);

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track);
    expect(EXPECTED_SHUFFLED_MANAGER, tracksToString(manager.queueTracks));
  });
}
