import 'dart:io';

import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/ui/page_playlist/playlist_page.dart';
import 'package:chrome_tube/ui/tracking/feature_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_cast_button/bloc_media_route.dart';
import 'package:flutter_google_cast_button/cast_button_widget.dart';

class SplashScreen extends StatefulWidget {
  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const PACKAGE_NAME = 'flutter_google_cast_button';
  static const CONNECTION_ASSETS = [
    'images/ic_cast0_black_24dp.png',
    'images/ic_cast1_black_24dp.png',
    'images/ic_cast2_black_24dp.png',
  ];

  String _errorMsg;
  AnimationController _animationController;
  Animation<String> connectingIconTween;

  @override
  void initState() {
    super.initState();
    FeatureService().init();
    PlaybackManager().init();
    _initToken();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    connectingIconTween = TweenSequence<String>(List.generate(
        CONNECTION_ASSETS.length,
        (i) => TweenSequenceItem<String>(
              tween: ConstantTween<String>(CONNECTION_ASSETS[i]),
              weight: 34.0,
            ))).animate(_animationController);
    connectingIconTween.addListener(() => setState(() {}));
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.forward(from: 0.0);
      }
    });
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
          setState(() => _errorMsg = typedError.message);
        } else {
          setState(() => _errorMsg = error.toString());
        }
        return;
      }
      await Future.delayed(const Duration(seconds: 3), () {});
      await Navigator.pushReplacement<void, void>(context,
          MaterialPageRoute(builder: (_) {
        return new PlaylistPage(playlists);
      }));
    } else {
      setState(() => _errorMsg = error);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            ? ImageIcon(
                ExactAssetImage(
                  connectingIconTween.value,
                  package: PACKAGE_NAME,
                ),
                size: 24,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Error:', style: theme.textTheme.headline6),
                  Text(_errorMsg,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headline6
                          .copyWith(color: theme.errorColor)),
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
