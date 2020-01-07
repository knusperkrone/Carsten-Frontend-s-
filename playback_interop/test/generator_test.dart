import 'package:collection/collection.dart';

import 'package:test/test.dart';
import 'package:playback_interop/playback_interop.dart';
import 'package:playback_interop/playback_interop_test.dart';

void main() {
  test('Random number generation - interop', () {
    // Execute
    final rand = new JavaRandom(GENERATE_SEED);
    final result = List.generate(EXPECTED_RANDS.length, (_) => rand.nextInt()).toList();

    // Validate
    const validator = ListEquality<int>();
    expect(validator.hash(EXPECTED_RANDS), validator.hash(result));
  });

  test('Random trackList generation - interop', () {
    // Execute
    final resultTracks = generateTracks();
    final resultString = tracksToString(resultTracks);

    // Validate
    expect(resultString, EXPECTED_GENERATED);
  });
}
