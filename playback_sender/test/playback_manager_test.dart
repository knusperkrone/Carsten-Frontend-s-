import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/common/ui_listener_state.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:playback_interop/playback_interop.dart';
import 'package:playback_interop/playback_interop_test.dart';

import 'mocks.dart';

void main() {
  UIListener listener;
  PlaybackManager manager;

  setUp(() {
    listener = new MockedUiListener();
    manager = new PlaybackManager.test(new MockedContext());
    manager.stream.listen(listener.onEvent);
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

  test('Interop manager not shuffling', () async {
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
    await Future.delayed(const Duration(milliseconds: 0), () {});
    verify(listener.onEvent(PlaybackUIEvent.QUEUE));

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track.value);
    expect(matcher.hash(expectedTail), matcher.hash(manager.queueTracks));
  });

  test('Interop manager shuffling', () async {
    // Prepare
    final mockedTracks = generateTracks();
    final PlaybackTrack expectedFirst = mockedTracks.first;
    final PlaybackQueueDto mockedDtoQueue = _generateMockQueueDto();

    final mockedState = new ShuffleStateDto(expectedFirst, true, SHUFFLE_SEED);

    // Execute
    manager.onQueue(mockedDtoQueue);
    manager.onShuffling(mockedState);

    // Verify
    await Future.delayed(const Duration(milliseconds: 0), () {});
    verify(listener.onEvent(PlaybackUIEvent.QUEUE)).called(2);

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track.value);
    expect(EXPECTED_SHUFFLED_MANAGER, tracksToString(manager.queueTracks));
  });

  test('Interop manager on/off shuffling', () async {
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
    await Future.delayed(const Duration(milliseconds: 0), () {});
    verify(listener.onEvent(PlaybackUIEvent.QUEUE)).called(3);

    // ignore: invalid_use_of_protected_member
    expect(expectedFirst, manager.track.value);
    expect(EXPECTED_SHUFFLED_MANAGER, tracksToString(manager.queueTracks));
  });
}
