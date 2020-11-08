import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/playback/src/playback_listeners.dart';
import 'package:chrome_tube/ui/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_cast_button/bloc_media_route.dart';
import 'package:flutter_google_cast_button/cast_button_widget.dart';

class QueueControl extends StatefulWidget {
  const QueueControl({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => QueueControlState();
}

class QueueControlState extends State<QueueControl> {
  final _manager = new PlaybackManager();

  MediaRouteBloc _mediaRouteBloc;

  @override
  void initState() {
    super.initState();
    _mediaRouteBloc = new MediaRouteBloc();
  }

  @override
  void dispose() {
    _mediaRouteBloc.close();
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  /*
   * UI-Callbacks
   */

  void _onPrev() => _manager.sendPrevious();

  void _onNext() => _manager.sendNext();

  void _onState() {
    if (_manager.currPlayerState == SimplePlaybackState.PAUSED) {
      _manager.sendPlay();
    } else if (_manager.currPlayerState == SimplePlaybackState.PLAYING) {
      _manager.sendPause();
    }
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 133,
      child: Column(
        children: [
          Stack(
            children: <Widget>[
              const Hero(
                tag: 'progress',
                child: LinearTrackSlider(
                  padding: 5.0,
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                child: const LinearProgressIndicator(),
                opacity:
                    (_manager.currPlayerState == SimplePlaybackState.BUFFERING)
                        ? 1.0
                        : 0.0,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(top: 5.0),
            child: Hero(
              tag: 'controls',
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 35.0,
                      onPressed: _manager.isConnected ? _onPrev : null,
                      splashColor: Theme.of(context).accentColor,
                    ),
                    IconButton(
                      icon: Icon(_manager.currPlayerState ==
                                  SimplePlaybackState.PAUSED ||
                              _manager.currPlayerState ==
                                  SimplePlaybackState.ENDED
                          ? Icons.play_arrow
                          : Icons.pause),
                      iconSize: 40.0,
                      onPressed: _manager.isConnected ? _onState : null,
                      splashColor: Theme.of(context).accentColor,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      iconSize: 35.0,
                      onPressed: _manager.isConnected ? _onNext : null,
                      splashColor: Theme.of(context).accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Hero(
              tag: 'cast',
              child: Material(
                color: Colors.transparent,
                child: CastButtonWidget(
                  bloc: _mediaRouteBloc,
                  tintColor: Colors.white70,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
