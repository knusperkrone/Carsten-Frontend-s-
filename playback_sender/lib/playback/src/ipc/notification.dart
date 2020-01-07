import 'dart:convert';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../playback.dart';

/*
 * Just hardcoded boilerplate
 */
class _BackgroundCacheManager extends BaseCacheManager {
  static const key = 'background_db';

  _BackgroundCacheManager() : super(key);

  @override
  Future<String> getFilePath() async {
    final directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }
}

class TrackIndicatorNoti {
  static Future<String> withTrack(PlaybackManager manager) async {
    if (!manager.track.isPresent) {
      return null;
    }
    // Load and convert file async
    final track = manager.track.value;
    final url = track.coverUrl;

    String imgB64;
    try {
      if (url != null) {
        final imgFile = await _BackgroundCacheManager().getSingleFile(url);
        if (imgFile != null) {
          final imgBytes = await imgFile.readAsBytes();
          imgB64 = base64.encode(imgBytes);
        }
      }
    } catch (e) {
      print('[ERROR] couldn\'t retrieve cover: $e');
    }

    return jsonEncode({
      'title': track.title,
      'artist': track.artist,
      'playlistName': 'Connected',
      'coverB64': imgB64,
      'isBuffering': manager.currPlayerState == SimplePlaybackState.BUFFERING,
      'isPlaying': manager.currPlayerState == SimplePlaybackState.PLAYING,
    });
  }
}
