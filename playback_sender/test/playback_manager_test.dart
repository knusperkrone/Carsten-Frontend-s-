import 'package:chrome_tube/playback/playback.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:playback_interop/playback_interop.dart';
import 'package:playback_interop/playback_interop_test.dart';

import 'mocks.dart';

void main() {
  PlaybackUIListener listener;
  PlaybackManager manager;

  setUp(() {
    listener = new MockedUiListener();
    manager = new PlaybackManager.test(new MockedContext());
    manager.registerListener(listener);
    reset(listener);
  });

  PlaybackQueueDto _generateMockQueueDto() {
    final List<PlaybackTrack> mockedDtoTracks = generateTracks();
    final PlaybackTrack first = mockedDtoTracks[0];
    return new PlaybackQueueDto(
        currentTrack: first,
        trackHolder: first,
        prioTracks: [],
        immutableTracks: mockedDtoTracks,
        name: 'name',
        hash: 'hash');
  }

  test('Interop manager not shuffling', () {
    // Prepare
    final mockedTracks = generateTracks();
    final PlaybackTrack expectedFirst = mockedTracks.first;
    final List<PlaybackTrack> expectedTail = mockedTracks;
    final PlaybackQueueDto mockedDtoQueue = _generateMockQueueDto();

    final mockedState = new ShuffleStateDto(expectedFirst, false, SHUFFLE_SEED);

    // Execute
    manager.onQueue(mockedDtoQueue);
    manager.onShuffling(mockedState);

    // Verify
    const matcher = ListEquality<PlaybackTrack>();
    verify(listener.notifyQueue()).called(1);

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track.value);
    expect(matcher.hash(expectedTail), matcher.hash(manager.queueTracks));
  });

  test('Interop manager shuffling', () {
    // Prepare
    final mockedTracks = generateTracks();
    final PlaybackTrack expectedFirst = mockedTracks.first;
    final PlaybackQueueDto mockedDtoQueue = _generateMockQueueDto();

    final mockedState = new ShuffleStateDto(expectedFirst, true, SHUFFLE_SEED);

    // Execute
    manager.onQueue(mockedDtoQueue);
    manager.onShuffling(mockedState);

    // Verify
    verify(listener.notifyQueue()).called(2);

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track.value);
    expect(EXPECTED_SHUFFLED_MANAGER, tracksToString(manager.queueTracks));
  });

  test('Interop manager on/off shuffling', () {
    // Prepare
    final mockedTracks = generateTracks();
    final PlaybackTrack expectedFirst = mockedTracks.first;
    final PlaybackQueueDto mockedDtoQueue = _generateMockQueueDto();

    final mockedState = new ShuffleStateDto(expectedFirst, true, SHUFFLE_SEED);

    // Execute
    manager.onQueue(mockedDtoQueue);
    manager.onShuffling(mockedState);
    manager.onQueue(mockedDtoQueue);

    // Verify
    verify(listener.notifyQueue()).called(3);

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track.value);
    expect(EXPECTED_SHUFFLED_MANAGER, tracksToString(manager.queueTracks));
  });
}
