import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/common/ui_listener_state.dart';
import 'package:flutter/material.dart';

import 'queue_control.dart';
import 'reorder_track_list.dart';

class QueuePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QueuePageState();
}

class _QueuePageState extends UIListenerState<QueuePage> {
  final _reorderKey = new GlobalKey<ReorderTrackListState>();
  final _controlKey = new GlobalKey<QueueControlState>();
  final _manager = new PlaybackManager();

  /*
   * PlaybackTrackUIListener contract
   */

  @override
  void onEvent(PlaybackUIEvent event) {
    switch (event) {
      case PlaybackUIEvent.REPEATING:
      case PlaybackUIEvent.PLAYER_STATE:
      case PlaybackUIEvent.READY:
        _controlKey.currentState?.rebuild();
        break;
      case PlaybackUIEvent.TRACK:
      case PlaybackUIEvent.QUEUE:
        _reorderKey.currentState?.rebuild();
        break;
      default:
    }
  }

  /*
   * build
   */

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(),
      body: !_manager.track.isPresent
          ? Container()
          : ReorderTrackList(key: _reorderKey),
      bottomNavigationBar: BottomAppBar(
        child: QueueControl(key: _controlKey),
      ),
    );
  }
}
