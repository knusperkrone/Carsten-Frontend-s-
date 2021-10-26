import 'package:playback_interop/playback_interop.dart';
import 'package:playback_interop/playback_interop_test.dart';
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
  group('Queue delta tests', () {
    late List<PlaybackTrack> tracks;
    late BasePlaybackQueue queue;

    setUp(() {
      tracks = generateTracks().sublist(0, 6);
      queue = new TestQueue(
        currentTrack: tracks.first,
        isShuffling: false,
        isRepeating: false,
        prioTracks: [],
        mutableTrackList: List.of(tracks),
      );
    });

    test('Add move to prio', () {
      const startIndex = 3;
      const startPrio = false;
      const targetIndex = 0;
      const targetPrio = true;

      // Execute
      final moveTrack = tracks[startIndex];
      queue.move(startPrio, startIndex, targetPrio, targetIndex);

      // Next song should be prio song
      queue.nextTrack();
      expect(moveTrack, queue.currentTrack);
      expect(true, queue.currentTrack!.isPrio);

      // Check rest of the list
      expect(true, tracks.remove(moveTrack));
      for (int i = 1; i < tracks.length; i++) {
        queue.nextTrack();
        expect(tracks[i], queue.currentTrack);
      }
      queue.nextTrack();
      expect(null, queue.currentTrack);
    });

    test('Add move to prio - 2x', () {
      const startIndex = 3;
      const startPrio = false;
      const targetIndex = 0;
      const targetPrio = true;

      // Execute
      final moveTrack1 = tracks[startIndex];
      queue.move(startPrio, startIndex, targetPrio, targetIndex);
      expect(true, tracks.remove(moveTrack1));
      final moveTrack2 = tracks[startIndex];
      queue.move(startPrio, startIndex, targetPrio, targetIndex);
      expect(true, tracks.remove(moveTrack2));

      // Next song should be prio song
      queue.nextTrack();
      expect(moveTrack2, queue.currentTrack);
      queue.nextTrack();
      expect(moveTrack1, queue.currentTrack);

      // Check rest of the list
      for (int i = 1; i < tracks.length; i++) {
        queue.nextTrack();
        expect(tracks[i], queue.currentTrack);
      }
      queue.nextTrack();
      expect(null, queue.currentTrack);
    });

    test('Move inside prio', () {
      // Prepare
      const startIndex = 3;
      const startPrio = false;
      const targetIndex = 0;
      const targetPrio = true;

      final moveTrack1 = tracks[startIndex];
      queue.move(startPrio, startIndex, targetPrio, targetIndex);
      expect(true, tracks.remove(moveTrack1));
      final moveTrack2 = tracks[startIndex];
      queue.move(startPrio, startIndex, targetPrio, targetIndex);
      expect(true, tracks.remove(moveTrack2));

      // Execute
      queue.move(true, 0, true, 1);

      // Next song should be prio song
      queue.nextTrack();
      expect(moveTrack1, queue.currentTrack);
      queue.nextTrack();
      expect(moveTrack2, queue.currentTrack);

      // Check rest of the list
      for (int i = 1; i < tracks.length; i++) {
        queue.nextTrack();
        expect(tracks[i], queue.currentTrack);
      }
      queue.nextTrack();
      expect(null, queue.currentTrack);
    });

    test('Move inside trackList', () {
      const startIndex = 3;
      const startPrio = false;
      const targetIndex = 1;
      const targetPrio = false;

      // Execute
      final moveTrack = tracks[startIndex];
      queue.move(startPrio, startIndex, targetPrio, targetIndex);

      // Validate
      tracks.insert(targetIndex, tracks.removeAt(startIndex));

      queue.nextTrack();
      expect(moveTrack, queue.currentTrack);
      for (int i = 1; i < tracks.length; i++) {
        expect(tracks[i], queue.currentTrack);
        queue.nextTrack();
      }
      expect(null, queue.currentTrack);
    });
  });
}
