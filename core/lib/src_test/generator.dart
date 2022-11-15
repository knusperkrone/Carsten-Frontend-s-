import '../playback_core.dart';
import 'constant.dart';

List<PlaybackTrack> generateTracks() {
  final rand = new JavaRandom(GENERATE_SEED);
  const artistCount = 15;
  const albumCount = 2;
  const songTreshold = 10;

  final tracks = <PlaybackTrack>[];
  int count = 0;
  for (int i = 0; i < artistCount; i++) {
    final artistName = String.fromCharCode('A'.codeUnitAt(0) + i);
    final songSize = rand.nextInt().abs() % songTreshold;
    for (int i2 = 0; i2 < albumCount; i2++) {
      final albumName = String.fromCharCode('G'.codeUnitAt(0) + i2);
      for (int j = 0; j < songSize; j++) {
        final trackName = '[$i]track: $j';
        final json = {
          'artist': artistName,
          'album': albumName,
          'title': trackName,
          'coverUrl': '',
          'queueIndex': count,
          'origQueueIndex': count,
          'isPrio': false,
          'durationMs': 0,
        };
        tracks.add(new PlaybackTrack.fromJson(json));
        count++;
      }
    }
  }
  return tracks;
}

String tracksToString(List<PlaybackTrack> tracks) => tracks.map((t) => t.artist[0]).join('');
