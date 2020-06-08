import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_cast_button/bloc_media_route.dart';
import 'package:flutter_google_cast_button/cast_button_widget.dart';
import 'package:playback_interop/playback_interop.dart';

import '../ui_listener_state.dart';

class ControlBar extends StatefulWidget {
  const ControlBar({Key key}) : super(key: key);

  @override
  State createState() => ControlBarState();
}

class ControlBarState extends UIListenerState<ControlBar> {
  // ignore: non_constant_identifier_names
  static final _PLACEHOLDER_TRACK =
      PlaybackTrack.dummy(title: 'No Track', artist: '');

  final _mediaKey = new GlobalKey<CastButtonWidgetState>();
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

  /*
   * Business logic
   */

  void refreshMediaState() {
    _mediaRouteBloc.close();
    _mediaRouteBloc = new MediaRouteBloc();
    _mediaKey.currentState.setBloc(_mediaRouteBloc);
  }

  /*
   * PlaybackTrackUIListener contract
   */

  @override
  void onEvent(PlaybackUIEvent event) {
    switch (event) {
      case PlaybackUIEvent.READY:
      case PlaybackUIEvent.PLAYER_STATE:
      case PlaybackUIEvent.QUEUE:
      case PlaybackUIEvent.TRACK:
        setState(() {});
        break;
      default:
    }
  }

  /*
   * UI callbacks
   */

  void _onOpen() {
    ControlPage.navigate(context).then((_) => refreshMediaState());
  }

  /*
   * Build
   */

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kToolbarHeight,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: _onOpen,
            child: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CastButtonWidget(
                    key: _mediaKey,
                    bloc: _mediaRouteBloc,
                    tintColor: Colors.white70,
                    backgroundColor: Colors.transparent,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        _manager.track.orElse(_PLACEHOLDER_TRACK).title,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _manager.track.orElse(_PLACEHOLDER_TRACK).artist,
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                  Container(width: 56.0)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
