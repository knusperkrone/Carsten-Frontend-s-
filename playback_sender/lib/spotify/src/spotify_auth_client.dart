import 'dart:convert';

import 'package:chrome_tube/utils/http_client_mixin.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'spotify_auth_client.g.dart';

@JsonSerializable()
class SerializableApiToken {
  @JsonKey(name: 'access_token')
  String accessToken;
  @JsonKey(name: 'refresh_token')
  final String refreshToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_in')
  final int expiresIn;
  @JsonKey()
  DateTime createdOn;

  SerializableApiToken(this.accessToken, this.refreshToken, this.tokenType,
      this.expiresIn, this.createdOn) {
    createdOn ??= DateTime.now();
  }

  factory SerializableApiToken.fromJsonSource(String source) => (source == null)
      ? null
      : _$SerializableApiTokenFromJson(
          jsonDecode(source) as Map<String, dynamic>);

  String toJsonSource() => jsonEncode(_$SerializableApiTokenToJson(this));

  bool get isExpired =>
      createdOn.difference(new DateTime.now()).inSeconds.abs() > expiresIn;
}

class AuthorizedSpotifyClient with DartHttpClientMixin {
  /*
   * Constants
   */

  static const String _BACKEND_BASE_URL =
      'https://integration.if-lab.de/arme-spotitube-backend/api/spotify';
  static const String _BASE_URL = 'https://api.spotify.com';
  static const String _TOKEN_KEY = 'SPOTIFY_API_SERIALIZED_TOKEN_KEY';

  /*
   * Members
   */

  final SharedPreferences _prefs;
  final String _authCode;
  SerializableApiToken _apiToken;

  AuthorizedSpotifyClient(this._prefs, this._authCode) {
    _apiToken =
        new SerializableApiToken.fromJsonSource(_prefs.getString(_TOKEN_KEY));
  }

  /*
   * Business methods
   */

  Future<String> authorizedGet(String path, {String baseUrl}) async {
    await _refreshToken();
    baseUrl ??= _BASE_URL;
    return doGet(
        baseUrl, path, {'Authorization': 'Bearer ${_apiToken.accessToken}'});
  }

  Future<String> authorizedPost(String path, String body,
      {String baseUrl = _BASE_URL}) async {
    await _refreshToken();
    baseUrl ??= _BASE_URL;
    return doPost(baseUrl, path,
        {'Authorization': 'Bearer ${_apiToken.accessToken}'}, body);
  }

  Future<String> authorizedPut(String path, String body,
      {String baseUrl = _BASE_URL}) async {
    await _refreshToken();
    baseUrl ??= _BASE_URL;
    return doPut<String>(baseUrl, path,
        {'Authorization': 'Bearer ${_apiToken.accessToken}'}, body);
  }

  /*
   * Token
   */

  Future<void> _refreshToken([int tryCount = 5]) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };

    try {
      if (_apiToken == null) {
        const path = '/create';
        final body = 'auth_code=${Uri.encodeQueryComponent(_authCode)}';

        // XXX: closed source call
        final respBody = await doPost(_BACKEND_BASE_URL, path, headers, body);
        _apiToken = new SerializableApiToken.fromJsonSource(respBody);

        _prefs.setString(_TOKEN_KEY, _apiToken.toJsonSource());
      } else if (_apiToken.isExpired) {
        const path = '/refresh';
        final body = 'refresh_token=${_apiToken.refreshToken}';
        SerializableApiToken refreshToken;

        // XXX: closed source call
        final respBody = await doPost(_BACKEND_BASE_URL, path, headers, body);
        refreshToken = new SerializableApiToken.fromJsonSource(respBody);

        _apiToken.accessToken = refreshToken.accessToken;
        _apiToken.createdOn = DateTime.now();
        _prefs.setString(_TOKEN_KEY, _apiToken.toJsonSource());
      }
    } catch (e) {
      if (tryCount-- <= 0) {
        rethrow;
      }

      print('[ERROR] refreshToken: $e tries[$tryCount/5]');
      return _refreshToken(tryCount);
    }
  }
}
