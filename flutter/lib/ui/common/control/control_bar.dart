import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/common/track_info.dart';
import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cast_button/bloc_media_route.dart';
import 'package:flutter_cast_button/cast_button_widget.dart';
import 'package:playback_core/playback_core.dart';

import '../state.dart';

class ControlBar extends StatefulWidget {
  const ControlBar({Key? key}) : super(key: key);

  @override
  State createState() => ControlBarState();
}

class ControlBarState extends UIListenerState<ControlBar> {
  PlaybackTrack? _trackSentinel;

  final _mediaKey = new GlobalKey<CastButtonWidgetState>();
  final _infoKey = new GlobalKey<TrackInfoState>();
  final _manager = new PlaybackManager();
  late MediaRouteBloc _mediaRouteBloc;

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
    _mediaKey.currentState?.setBloc(_mediaRouteBloc);
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
        final track = _manager.track ?? _trackSentinel!;
        _infoKey.currentState?.setTrack(track);
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
    _trackSentinel ??= new PlaybackTrack.dummy(
      title: locale.translate('no_song_title'), // requires context
      artist: '',
    );

    return Container(
      height: kToolbarHeight,
      color: theme.primaryColor,
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
                  Expanded(
                    child: TrackInfo(
                      key: _infoKey,
                      track: _manager.track ?? _trackSentinel!,
                      titleHeight: kToolbarHeight / 2.0,
                      artistHeight: kToolbarHeight / 2.0,
                      blank: 30,
                    ),
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
