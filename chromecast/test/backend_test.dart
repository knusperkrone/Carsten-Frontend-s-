import 'package:playback_caf_dart/src/playback/backend.dart';
import 'package:playback_core/playback_core.dart';
import 'package:test/test.dart';

void main() {
  test('Fetch youtube id', () async {
    final track = new PlaybackTrack.dummy();
    final resp = await BackendAdapter().getVideoId(track);
    expect(resp, '1SG5A3PYaUs');
  });
}
