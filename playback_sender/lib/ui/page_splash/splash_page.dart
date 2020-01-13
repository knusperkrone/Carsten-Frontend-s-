import 'dart:io';

import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/ui/page_playlist/playlist_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _errorMsg;

  @override
  void initState() {
    super.initState();
    PlaybackManager().init();
    _initToken();
  }

  Future<void> _initToken() async {
    final error = await SpotifyApi().init(context);
    if (error == null) {
      List<SpotifyPlaylist> playlists;
      try {
        playlists = await SpotifyApi().getUserPlaylists();
      } catch (error) {
        if (error is SocketException) {
          final typedError = error;
          setState(() => _errorMsg = typedError.osError.toString());
        } else {
          setState(() => _errorMsg = error.toString());
        }
        return;
      }
      await Navigator.pushReplacement<void, void>(context, MaterialPageRoute(builder: (_) {
        return new PlaylistPage(playlists);
      }));
    } else {
      setState(() => _errorMsg = error);
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return new Scaffold(
      body: Center(
        child: _errorMsg == null
            ? Icon(Icons.cast_connected)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Error:', style: theme.textTheme.title),
                  Text(_errorMsg,
                      textAlign: TextAlign.center, style: theme.textTheme.title.copyWith(color: theme.errorColor)),
                  OutlineButton(
                    child: const Text('Retry'),
                    onPressed: _initToken,
                  ),
                ],
              ),
      ),
    );
  }
}
