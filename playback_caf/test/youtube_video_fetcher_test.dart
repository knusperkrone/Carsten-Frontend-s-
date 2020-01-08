import 'package:playback_caf_dart/src/playback/youtube_video_fetcher.dart';
import 'package:test/test.dart';

void main() {
  group('YoutubeVideoFetcher', () {
    test('Youtube fetch cipher', () async {
      final result = await YotubeVideoFetcher.fetch('QryoOF5jEbc');
      expect(true, result.isNotEmpty);
      expect(Uri.tryParse(result.first.url), (Uri uri) => uri != null);
    });

    test('Youtube fetch url', () async {
      final result = await YotubeVideoFetcher.fetch('byZBO7EHnFQ');
      expect(true, result.isNotEmpty);
      expect(Uri.tryParse(result.first.url), (Uri uri) => uri != null);
    });
  });
}
