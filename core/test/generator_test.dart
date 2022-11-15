import 'package:collection/collection.dart';
import 'package:playback_core/playback_core.dart';
import 'package:playback_core/playback_core_test.dart';
import 'package:test/test.dart';

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
