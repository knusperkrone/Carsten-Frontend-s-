import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/common/common.dart';
import 'package:chrome_tube/ui/common/ui_listener_state.dart';
import 'package:chrome_tube/utils/forked/reorderable_sliver/reorderable_sliver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_cast_button/bloc_media_route.dart';
import 'package:flutter_google_cast_button/cast_button_widget.dart';
import 'package:playback_interop/playback_interop.dart';

class QueuePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _QueuePageState();
}

class _QueuePageState extends UIListenerState<QueuePage>
    with SingleTickerProviderStateMixin {
  // ignore: non_constant_identifier_names
  static final _PLACEHOLDER_TRACK =
      new PlaybackTrack.dummy(artist: '', coverUrl: '', title: '');

  final _manager = new PlaybackManager();
  MediaRouteBloc _mediaRouteBloc;
  AnimationController _animController;

  List<PlaybackTrack> _prioTracks;
  List<PlaybackTrack> _queueTracks;

  @override
  void initState() {
    super.initState();
    _prioTracks = List.from(_manager.prioTracks);
    _queueTracks = List.from(_manager.queueTracks);

    _mediaRouteBloc = new MediaRouteBloc();
    _animController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _animController.value = _prioTracks.isEmpty ? 0.0 : 1.0;
  }

  @override
  void dispose() {
    _mediaRouteBloc.close();
    _animController.dispose();
    super.dispose();
  }

  /*
   * PlaybackTrackUIListener contract
   */

  @override
  void onEvent(PlaybackUIEvent event) {
    switch (event) {
      case PlaybackUIEvent.REPEATING:
      case PlaybackUIEvent.PLAYER_STATE:
      case PlaybackUIEvent.READY:
        setState(() {});
        break;
      case PlaybackUIEvent.TRACK:
      case PlaybackUIEvent.QUEUE:
        setState(() {
          _prioTracks = List.from(_manager.prioTracks);
          _queueTracks = List.from(_manager.queueTracks);
        });
        break;
      default:
    }
  }

  /*
   * UI callbacks
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
   * Reorderables contract
   */

  bool _canReorder(int i) => i != _prioTracks.length;

  void _onStartReorder() {
    if (_animController.value == 0.0) {}
  }

  void _onReorder(int startIndex, int targetIndex) {
    setState(() {
      final startPrio = startIndex <= _prioTracks.length;
      bool targetPrio = targetIndex <= _prioTracks.length;
      // targetPrio might be wrong, as we drag on the barrier
      if ((startPrio && targetPrio) &&
          (_prioTracks.isNotEmpty && _prioTracks.length == targetIndex)) {
        targetPrio = false;
      }

      // get lists
      final startList = startPrio ? _prioTracks : _queueTracks;
      final targetList = targetPrio ? _prioTracks : _queueTracks;

      // targetList index offset
      if (!startPrio) {
        startIndex -= _prioTracks.length;
      }
      if (!targetPrio) {
        targetIndex -= _prioTracks.length;
      }

      // normal queue has the barrier offset
      startIndex -= !startPrio ? 1 : 0;
      targetIndex -= !targetPrio ? 1 : 0;

      // current track offset
      startIndex += !startPrio ? _manager.trackIndex + 1 : 0;
      targetIndex += !targetPrio ? _manager.trackIndex + 1 : 0;

      // local list swap
      final localStartIndex = startIndex;
      int localTargetIndex = targetIndex;
      if (startPrio && !targetPrio) {
        targetIndex += 1;
        localTargetIndex += 1; // Over barrier
      }
      final row = startList.removeAt(localStartIndex);
      targetList.insert(localTargetIndex, row);

      // send to manager and wait for the broadcast!
      _manager.sendMove(startPrio, startIndex, targetPrio, targetIndex);
    });
  }

  /*
   * build
   */

  Widget _buildTile(PlaybackTrack track) {
    final theme = Theme.of(context);
    final curr = track;
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        height: 50,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.album,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  curr?.title ?? '',
                  overflow: TextOverflow.fade,
                  style: theme.textTheme.subtitle1.copyWith(fontSize: 16.0),
                ),
                Text(
                  curr?.artist ?? '',
                  style: TextStyle(
                      color: theme.textTheme.caption.color, fontSize: 13.0),
                ),
              ],
            ),
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Icon(Icons.drag_handle),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTrackList() {
    final prioTracks = _prioTracks.map((t) => _buildTile(t));

    final barrier = Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 7.0),
      child: Text(
        'Next song from ${_manager.playlistName}:',
        style: Theme.of(context).textTheme.headline6,
      ),
    );

    final trackOffset = _manager.trackIndex + 1;
    final queueTracks =
        _queueTracks.skip(trackOffset).map((t) => _buildTile(t)).toList();

    if (queueTracks.isEmpty) {
      return prioTracks.toList();
    }
    return List.from(prioTracks)
      ..add(barrier)
      ..addAll(queueTracks);
  }

  @override
  Widget build(BuildContext context) {
    if (_prioTracks.isEmpty) {
      _animController.reverse();
    } else {
      _animController.forward();
    }

    return new Scaffold(
      appBar: AppBar(),
      body: !_manager.track.isPresent
          ? Container()
          : CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 7.0),
                    child: Text(
                      'Current Title:',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl:
                          _manager.track.orElse(_PLACEHOLDER_TRACK).coverUrl,
                      placeholder: (_, __) => Container(width: 56.0),
                    ),
                    title:
                        Text(_manager.track.orElse(_PLACEHOLDER_TRACK).title),
                    subtitle:
                        Text(_manager.track.orElse(_PLACEHOLDER_TRACK).artist),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return Container(
                        width: double.infinity,
                        height: 40 * _animController.value,
                        child: _animController.value > 0.7
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 7.0),
                                child: Opacity(
                                  opacity: _animController.value,
                                  child: Text(
                                    'Next song from queue:',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
                ReorderableSliverList(
                  onStartReorder: _onStartReorder,
                  canReorder: _canReorder,
                  onReorder: _onReorder,
                  delegate:
                      ReorderableSliverChildListDelegate(_buildTrackList()),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
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
                    opacity: (_manager.currPlayerState ==
                            SimplePlaybackState.BUFFERING)
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
                          icon: Icon(Icons.skip_previous),
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
                          icon: Icon(Icons.skip_next),
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
        ),
      ),
    );
  }
}
