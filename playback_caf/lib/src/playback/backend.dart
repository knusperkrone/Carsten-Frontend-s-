import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:playback_interop/playback_interop.dart';

class BackendAdapter {
  final client = new HttpClient();

  BackendAdapter() {
    // Certificate workaround
    client.badCertificateCallback = (X509Certificate _, String __, int ___) => true;
  }

  Future<String> getVideoId(PlaybackTrack track) async {
    final key = '${track.title} ${track.artist}';
    String id;
    try {
      final uri = Uri.https(
        'spotitube.if-lab.de',
        '/api/youtube/search',
        {'q': key},
      );

      final request = await client.getUrl(uri);
      final resp = await request.close();
      final respBody = await _readResponse(resp);

      if (resp.statusCode != 200) {
        throw new StateError('Invalid status code: ${resp.statusCode}\n$respBody');
      }
      id = jsonDecode(respBody)['id'] as String;
      if (id == null) {
        throw new StateError('Invalid id with request ${resp.statusCode}\n$respBody');
      }
    } catch (e) {
      print('[ERROR] couldn\'t get Video id: $id\n$e');
    }
    return id ?? 'QryoOF5jEbc'; // Fallback is twerk
  }

  Future<String> _readResponse(HttpClientResponse response) {
    final completer = new Completer<String>();
    final contents = new StringBuffer();
    response.transform(utf8.decoder).listen((data) {
      contents.write(data);
    }, onDone: () => completer.complete(contents.toString()));
    return completer.future;
  }
}
