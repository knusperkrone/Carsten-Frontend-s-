import 'dart:convert';

import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/spotify/src/dto/spotify_featured.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeatureService {
  /*
   * Singleton logic
   */

  static FeatureService _instance;

  factory FeatureService() {
    _instance ??= FeatureService._internal();
    return _instance;
  }

  FeatureService._internal();

  /*
   * Business logic
   */

  static const String _FEATURE_KEY = 'featured_v1';

  SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void addFeature(SpotifyFeatured newFeatured) {
    final featured = getLastFeatured();
    if (featured.contains(newFeatured)) {
      return;
    }
    featured.insert(0, newFeatured);
    while (featured.length > 6) {
      featured.removeLast();
    }

    final jsonStrings = featured.map((f) => jsonEncode(f.toJson())).toList();
    _prefs.setStringList(_FEATURE_KEY, jsonStrings);
  }

  List<SpotifyFeatured> getLastFeatured() {
    final jsonStrings = _prefs.getStringList(_FEATURE_KEY) ?? [];
    final featured = <SpotifyFeatured>[];
    for (final jsonString in jsonStrings) {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      if (map.containsKey('snapshot_id')) {
        featured.add(SpotifyPlaylist.fromJson(map));
      } else {
        featured.add(SpotifyAlbum.fromJson(map));
      }
    }

    return featured;
  }
}
