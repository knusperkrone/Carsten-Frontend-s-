import 'package:playback_core/playback_core.dart';
import 'package:playback_core/playback_core_test.dart';
import 'package:test/test.dart';

class TestQueue extends BasePlaybackQueue {
  TestQueue(
      {required PlaybackTrack currentTrack,
      required bool isShuffling,
      required bool isRepeating,
      required List<PlaybackTrack> prioTracks,
      required List<PlaybackTrack> mutableTrackList})
      : super(currentTrack, isShuffling, isRepeating, prioTracks, mutableTrackList);
}

void main() {
  group('Queue tests', () {
    late List<PlaybackTrack> tracks;
    late BasePlaybackQueue queue;

    setUp(() {
      tracks = generateTracks();
      queue = new TestQueue(
        currentTrack: tracks.first,
        isShuffling: false,
        isRepeating: false,
        prioTracks: [],
        mutableTrackList: tracks,
      );
    });

    test('First track', () {
      expect(tracks.first, queue.currentTrack);
    });

    test('All tracks forward', () {
      for (int i = 0; i < tracks.length; i++) {
        expect(tracks[i], queue.currentTrack);
        expect(queue.currentTrack!.queueIndex, i);
        queue.nextTrack();
      }
      expect(null, queue.currentTrack);
    });

    test('All tracks backward', () {
      for (int i = 0; i < tracks.length - 1; i++) {
        queue.nextTrack();
      }

      for (int i = tracks.length - 1; i >= 0; i--) {
        expect(tracks[i], queue.currentTrack);
        queue.previousTrack();
      }
      expect(tracks.first, queue.currentTrack);
    });

    test('Repeating', () {
      queue.setRepeating(true);
      for (int i = 0; i < tracks.length; i++) {
        expect(tracks[i], queue.currentTrack);
        expect(queue.currentTrack!.queueIndex, i);
        queue.nextTrack();
      }
      for (int i = 0; i < tracks.length; i++) {
        expect(tracks[i], queue.currentTrack);
        expect(queue.currentTrack!.queueIndex, i);
        queue.nextTrack();
      }
    });

    test('PrioList', () {
      int i;
      for (i = 0; i < tracks.length / 2; i++) {
        queue.nextTrack();
      }

      final prioTracks = List.generate(4, (i) => PlaybackTrack.copyWithPrio(true, PlaybackTrack.dummy()));
      prioTracks.forEach((t) => queue.addPrioTrack(t, true));

      i++;
      queue.nextTrack();
      for (final prioTrack in prioTracks) {
        expect(prioTrack, queue.currentTrack);
        queue.nextTrack();
      }

      for (; i < tracks.length; i++) {
        expect(tracks[i], queue.currentTrack);
        queue.nextTrack();
      }
    });
  });
}
