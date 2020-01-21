import 'dart:convert';

import 'package:playback_interop/playback_interop.dart';
import 'package:http/http.dart' as http;

class BackendAdapter {
  Future<String> getVideoId(PlaybackTrack track) async {
    final key = '${track.title} ${track.artist}';
    String id;
    try {
      final uri = Uri.https(
        'spotitube.if-lab.de',
        '/api/youtube/search',
        {'q': key},
      );
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw new StateError('Invalid status code: ${resp.statusCode}\n${resp.body}');
      }
      id = jsonDecode(resp.body)['id'] as String;
      if (id == null) {
        throw new StateError('Invalid id with request ${resp.statusCode}\n${resp.body}');
      }
    } catch (e) {
      print('[ERROR] couldn\'t get Video id: $id\n$e');
    }
    return id ?? 'QryoOF5jEbc'; // Fallback is twerk
  }
}
