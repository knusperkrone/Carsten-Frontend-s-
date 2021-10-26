import 'dart:collection';
import 'dart:math';

import 'package:fixnum/fixnum.dart';

import 'dto/dto.dart';

class JavaRandom {
  static const MUL = 0x5deece66d;
  static const ADD = 0xb;
  // static const MASK = (1 << 48) - 1;
  // ignore: non_constant_identifier_names
  static final MASK = new Int64.fromInts((1 << 16) - 1, (1 << 32) - 1);

  late Int64 _seed;

  JavaRandom(int initSeed) {
    if (initSeed > Int32.MAX_VALUE.toInt()) {
      throw ArgumentError('seeds needs to be smaller than ${Int32.MAX_VALUE.toInt()}, was: $initSeed');
    }
    final seed = new Int64.fromInts(0, initSeed);
    _setSeed(seed);
  }

  void _setSeed(Int64 newSeed) => _seed = (newSeed ^ MUL) & MASK;

  int nextInt() => _next(32).toInt32().toInt();

  Int64 _next(int bits) {
    _seed = (_seed * MUL + ADD) & MASK;
    return ((_seed ~/ 0x10000) >> (32 - bits)).toSigned(bits);
  }
}

// Helper classes
typedef _GroupByCriteria = String Function(PlaybackTrack toGroup);

class _Tuple<T, T2> {
  final T x;
  final T2 y;

  _Tuple(this.x, this.y);
}

class PlaybackShuffler {
  // ignore: non_constant_identifier_names
  static final PlaybackTrack DUMMY_TRACK = new PlaybackTrack.dummy(); // NULL values are not allowed

  late JavaRandom _mRand;

  /// A cross platform shuffle algorithm, to avoid unnecessary syncing
  ///
  /// @param seed      cross platform seed
  /// @param toShuffle the to shuffle list without the first song
  /// @return a new allocated and "human-randomized" list
  List<PlaybackTrack> shuffle(int seed, List<PlaybackTrack> toShuffle) {
    _mRand = new JavaRandom(seed);
    if (toShuffle.length < 256) {
      return _shuffle(toShuffle, [
        (t) => t.artist,
        (t) => t.album,
      ]);
    }
    return _shuffle(toShuffle, [(t) => t.artist]);
  }

  /// Algorithm by:
  /// https://labs.spotify.com/2014/02/28/how-to-shuffle-songs/
  /// http://keyj.emphy.de/balanced-shuffle/
  ///
  /// @param toShuffle the list to shuffle
  /// @param criterias list of attributes to group and non-uniform distribute the tracks
  /// @return a new allocated and "human-randomized" list
  List<PlaybackTrack> _shuffle(List<PlaybackTrack> toShuffle, List<_GroupByCriteria> criterias) {
    final criteria = criterias.removeAt(0);

    // Group by criteria
    final grouped = new HashMap<String, List<PlaybackTrack>>();
    for (final currTrack in toShuffle) {
      final key = criteria(currTrack);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(currTrack);
    }

    // Sort keys for cross-platform interop
    // SELECT key FROM grouped ORDER BY length, criteria
    int i = 0;
    final sortedTuples = new List<_Tuple<List<PlaybackTrack>, String>>.filled(grouped.keys.length, _Tuple([], ''));
    for (final entry in grouped.entries) {
      sortedTuples[i++] = new _Tuple(entry.value, entry.key);
    }
    sortedTuples.sort((final a, final b) {
      if (b.x.length == a.x.length) {
        return b.y.toLowerCase().compareTo(a.y.toLowerCase()); // strcmp
      }
      return b.x.length - a.x.length;
    });

    // Non uniform distribute track along the longest list
    final longestListSize = sortedTuples[0].x.length;
    final filledUpTracks = <List<PlaybackTrack>>[];
    for (_Tuple<List<PlaybackTrack>, String> sortTuple in sortedTuples) {
      List<PlaybackTrack> trackList = sortTuple.x;
      if (criterias.isNotEmpty && trackList.length > 1) {
        // Recursive shuffle
        trackList = _shuffle(trackList, List.of(criterias));
      }

      final filledList = _fill(trackList, longestListSize);
      filledUpTracks.add(filledList);
    }

    return _merge(filledUpTracks, longestListSize, criteria);
  }

  List<PlaybackTrack> _fill(List<PlaybackTrack> inputList, int longestListSize) {
    if (inputList.length == longestListSize || inputList.isEmpty) {
      return inputList;
    }

    final sparsedArray = new List.filled(longestListSize, DUMMY_TRACK);

    int i = 0;
    int n = longestListSize;
    while (true) {
      sparsedArray[i] = inputList.removeAt(0); // Pop
      if (inputList.isEmpty) {
        break;
      }

      final k = inputList.length; // Elements left
      double r = n / k; // Segmentation length (floating!)

      // +/- 10% randomization
      final rVal = _mRand.nextInt();
      final toss = rVal.remainder(10);
      r = (r + ((r / 100) * toss)).roundToDouble();

      r = min((n - k).toDouble(), r); // k-1 segments must still fit
      r = max(1.0, r); // But at least 1 segment

      i += r.toInt();
      n -= r.toInt();
    }

    // Add random offset to list
    final randOffset = (_mRand.nextInt().remainder(longestListSize + 1)).abs().toInt();
    final sparsedList = List.of(sparsedArray);
    return _rotate(sparsedList, randOffset);
  }

  /// Merges two non-uniform distributed lists
  ///
  /// @param filledUpLists list with @longestListSize, filled with dummies
  /// @param longestListSize maximal list size
  /// @param criteria getter for penalty checking
  /// @return new "perfectly" shuffled List
  List<PlaybackTrack> _merge(List<List<PlaybackTrack>> filledUpLists, int longestListSize, _GroupByCriteria criteria) {
    final merged = <PlaybackTrack>[];

    for (int i = 0; i < longestListSize; i++) {
      // Get all non-dummy tracks from current index
      final selectedTrackList = <PlaybackTrack>[];
      for (final filledUp in filledUpLists) {
        if (filledUp[i] != DUMMY_TRACK) {
          selectedTrackList.add(filledUp[i]);
        }
      }

      // Random shuffle
      _fisherYatesShuffle(selectedTrackList);

      // Check for penalty and move fist element to the end
      if (selectedTrackList.length > 1 && merged.isNotEmpty) {
        final currFirst = selectedTrackList.first;
        final lastInserted = merged.last;
        if (criteria(currFirst) == (criteria(lastInserted)) && selectedTrackList.length != 1) {
          selectedTrackList.add(selectedTrackList.removeAt(0)); // Shift to end
        }
      }

      merged.addAll(selectedTrackList);
    }

    return merged;
  }

  /// Cross platform rotates an collection
  ///
  /// @param list  input list
  /// @param times rotate count
  /// @param <T>   list type
  /// @return rotated list
  List<T> _rotate<T>(List<T> list, int times) {
    while (times-- != 0) {
      final hold = list.removeAt(0);
      list.add(hold);
    }
    return list;
  }

  /// Algorithm by:
  /// https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
  ///
  /// @param toShuffle the playlist to shuffle
  /// @param <T>       list generic
  void _fisherYatesShuffle<T>(List<T> toShuffle) {
    for (int i = toShuffle.length - 1; i >= 0; i--) {
      final j = (_mRand.nextInt().remainder(i + 1)).abs().toInt(); // 0 <= j <= i
      final hold = toShuffle[j];
      toShuffle[j] = toShuffle[i];
      toShuffle[i] = hold;
    }
  }
}
