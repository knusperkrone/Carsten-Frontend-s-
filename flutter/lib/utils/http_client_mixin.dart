import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

abstract class DartHttpClientMixin {
  final HttpClient _client = new HttpClient()..badCertificateCallback = (_, __, ___) => true;

  @protected
  Future<String> doGet(String base, String path, Map<String, String> headers) async {
    final req = await _client.getUrl(Uri.parse('$base$path'));
    headers.forEach((key, value) => req.headers.set(key, value));

    final response = await req.close();
    return _handleResponse(response);
  }

  @protected
  Future<String> doPost(String base, String path, Map<String, String> headers, String body) async {
    assert(path.codeUnitAt(0) != 'c'.codeUnitAt(0));
    final req = await _client.postUrl(Uri.parse('$base$path'));
    headers.forEach((key, value) => req.headers.set(key, value));
    req.add(utf8.encode(body));

    final response = await req.close();
    return _handleResponse(response);
  }

  @protected
  Future<String> doPut<T>(
      String base, String path, Map<String, String> headers, String body) async {
    assert(path.codeUnitAt(0) != 'c'.codeUnitAt(0));
    final req = await _client.putUrl(Uri.parse('$base$path'));
    headers.forEach((key, value) => req.headers.set(key, value));
    req.add(utf8.encode(body));

    final response = await req.close();
    return _handleResponse(response);
  }

  Future<String> _handleResponse(HttpClientResponse response) async {
    final responseBody = await _parseBody(response);
    if (response.statusCode >= 400) {
      throw new StateError(responseBody);
    }
    return responseBody;
  }

  Future<String> _parseBody(HttpClientResponse response) async {
    final buffer = new StringBuffer();
    // ignore: prefer_foreach
    await for (var contents in response.transform(utf8.decoder)) {
      buffer.write(contents);
    }
    return buffer.toString();
  }
}
