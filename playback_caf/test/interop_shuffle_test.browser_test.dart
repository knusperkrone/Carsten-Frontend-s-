import 'dart:convert';

import 'package:playback_interop/playback_interop.dart';
import 'package:playback_interop/playback_interop_test.dart';
import 'package:test/test.dart';

void main() {
  test('Interop shuffling', () {
    final shuffler = new PlaybackShuffler();
    final result = shuffler.shuffle(SHUFFLE_SEED, generateTracks());
    final resultString = tracksToString(result);

    expect(EXPECTED_SHUFFLED_SHUFFLER, resultString);
  });

  test('Interop shuffling - short', () {
    final shuffler = new PlaybackShuffler();
    final list = json.decode(INTEGRATION_TRACKS) as List<dynamic>;
    final List<dynamic> untyped =
        list.map((dynamic json) => PlaybackTrack.fromJson(json as Map<String, dynamic>)).toList();
    final List<PlaybackTrack> tracks = untyped.cast();

    final List<PlaybackTrack> result = shuffler.shuffle(0, tracks);
    final resultString = result.map((r) => r.title).join(',');
    expect('Beaches,3WW,Aftermath,Nein - Prod. 2Rvr3Beatz', resultString);
  });
}
