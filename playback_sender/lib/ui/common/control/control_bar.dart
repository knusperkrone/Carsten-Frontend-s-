import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_cast_button/bloc_media_route.dart';
import 'package:flutter_google_cast_button/cast_button_widget.dart';
import 'package:playback_interop/playback_interop.dart';

class ControlBar extends StatefulWidget {
  @override
  State createState() => ControlBarState();
}

class ControlBarState extends State<ControlBar> implements PlaybackUIListener {
  // ignore: non_constant_identifier_names
  static final _PLACEHOLDER_TRACK =
      PlaybackTrack.dummy(title: 'No Track', artist: '');

  final _manager = new PlaybackManager();
  MediaRouteBloc _mediaRouteBloc;

  @override
  void initState() {
    super.initState();
    _manager.registerListener(this);
    _mediaRouteBloc = new MediaRouteBloc();
  }

  @override
  void dispose() {
    _manager.unregisterListener(this);
    super.dispose();
  }

  /*
   * PlaybackTrackUIListener contract
   */

  @override
  void notifyPlaybackReady() => setState(() {});

  @override
  void notifyPlayingState() => setState(() {});

  @override
  void notifyQueue() => setState(() {});

  @override
  void notifyTrack() => setState(() {});

  @override
  void notifyRepeating() {}

  @override
  void notifyTrackSeek() {}

  /*
   * UI callbacks
   */

  Future<void> _onOpen() async {
    return await ControlPage.navigate(context);
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
