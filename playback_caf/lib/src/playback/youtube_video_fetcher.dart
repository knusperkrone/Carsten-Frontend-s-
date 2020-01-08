import 'dart:convert';
import 'package:meta/meta.dart';

import 'package:http/http.dart' as http;

Map _urlFormencodedToMap(String string) {
  final map = <String, String>{};
  final ampSplit = string.split('&');
  for (final s in ampSplit) {
    final equalsSplit = s.split('=');
    if (equalsSplit.length == 2) {
      map[equalsSplit[0]] = equalsSplit[1];
    }
  }
  return map;
}

class YoutubeVideo {
  final int width;
  final int height;
  final int approxDurationMs;
  final String url;
  final String mimeType;

  YoutubeVideo._({
    @required this.width,
    @required this.height,
    @required this.approxDurationMs,
    @required this.url,
    @required this.mimeType,
  }) : assert(width != null && height != null && url != null && mimeType != null);

  factory YoutubeVideo.fromJson(Map<String, dynamic> json) {
    String url;
    if (json.containsKey('cipher')) {
      final cipherMap = _urlFormencodedToMap(json['cipher'] as String);
      url = Uri.decodeQueryComponent(cipherMap['url'] as String);
    } else {
      url = json['url'] as String;
    }

    return new YoutubeVideo._(
      width: json['width'] as int,
      height: json['height'] as int,
      approxDurationMs: int.tryParse((json['approxDurationMs'] as String) ?? ''), // nullable
      url: url,
      mimeType: json['mimeType'] as String,
    );
  }

  int get size => width * height;
}

class YotubeVideoFetcher {
  static const _RESP_KEY = 'player_response';
  static const _STREAMING_KEY = 'streamingData';
  static const _FORMAT_KEY = 'formats';

  static Future<List<YoutubeVideo>> fetch(String vId) async {
    final resp = await http.get('https://www.youtube.com/get_video_info?&video_id=$vId&asv=3&el=detailpage&hl=de_DE');

    final map = _urlFormencodedToMap(resp.body);

    if (!map.containsKey(_RESP_KEY)) {
      throw StateError("Coulnd't parse response for version: ${map['innertube_api_version']}");
    }

    final results = <YoutubeVideo>[];
    try {
      final json = jsonDecode(Uri.decodeQueryComponent(map[_RESP_KEY] as String)) as Map<String, dynamic>;
      for (final Map<String, dynamic> listJson in json[_STREAMING_KEY][_FORMAT_KEY]) {
        results.add(new YoutubeVideo.fromJson(listJson));
      }
    } catch (e) {
      rethrow;
    }

    return results;
  }
}
