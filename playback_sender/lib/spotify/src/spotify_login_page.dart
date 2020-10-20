import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SpotifyLoginPageResult {
  final String code;
  final String error;

  SpotifyLoginPageResult(this.code, this.error);
}

class SpotifyLoginPage extends StatelessWidget {
  /*
   * Constants
   */

  static const _REDIRECT_URL =
      'https://integration.if-lab.de/arme-spotitube-backend/api/spotify/callback';
  static const _CLIENT_ID = '2b217a32857645b79e60dda0a56b2268';
  static const _TYPE = 'code';
  static const _SCOPES = [
    'user-read-private',
    'user-library-read',
    'playlist-read',
    'playlist-read-private',
    'playlist-read-collaborative',
  ];

  /*
   * Members
   */

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final url = 'https://accounts.spotify.com/authorize'
      '?client_id=$_CLIENT_ID'
      '&response_type=$_TYPE'
      '&redirect_uri=${Uri.encodeQueryComponent(_REDIRECT_URL)}'
      '&scope=${_SCOPES.join('%20')}'
      '&state=34fFs29kd09';

  /*
   * Callbacks
   */

  void _onTokenCheck(String loadedUri, BuildContext context) {
    if (loadedUri.startsWith(_REDIRECT_URL)) {
      // Parse return code url
      final uri = Uri.parse(loadedUri);
      final token = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];
      Navigator.pop<SpotifyLoginPageResult>(
          context, new SpotifyLoginPageResult(token, error));
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        actions: const <Widget>[],
        title: const Text('Spotify Login'),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: WebView(
          initialUrl: url,
          debuggingEnabled: false,
          javascriptMode: JavascriptMode.unrestricted,
          initialMediaPlaybackPolicy:
              AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          onPageFinished: (uri) => _onTokenCheck(uri, context),
        ),
      ),
    );
  }
}
