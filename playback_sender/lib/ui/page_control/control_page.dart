import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/common/common.dart';
import 'package:chrome_tube/ui/common/ui_listener_state.dart';
import 'package:chrome_tube/ui/page_control/track_app_bar.dart';
import 'package:chrome_tube/ui/page_control/track_gradient.dart';
import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_cast_button/bloc_media_route.dart';
import 'package:flutter_google_cast_button/cast_button_widget.dart';
import 'package:optional/optional.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:playback_interop/playback_interop.dart';

part 'track_control.dart';

part 'track_pages.dart';

part 'track_progress.dart';

part 'track_title.dart';

class ControlPage extends StatefulWidget {
  @override
  State createState() => new ControlPageState();

  final Color baseColor;

  const ControlPage._(this.baseColor);

  static Future<void> navigate(BuildContext context) async {
    final baseColor = PlaybackManager().track.isPresent
        ? Theme.of(context).canvasColor
        : Theme.of(context).primaryColor;
    return Navigator.push<void>(context, new MaterialPageRoute(builder: (context) {
      return new ControlPage._(baseColor);
    }));
  }
}

class ControlPageState extends UIListenerState<ControlPage>
    with SingleTickerProviderStateMixin {
  final PlaybackManager _manager = new PlaybackManager();
  final ColorTween _colorTween = new ColorTween();
  final Duration _animDelay = const Duration(milliseconds: 250);

  final GlobalKey<TrackAppBarState> _barKey = new GlobalKey();
  final GlobalKey<TrackDetailsState> _detailKey = new GlobalKey();
  final GlobalKey<TrackPagesState> _pageKey = new GlobalKey();
  final GlobalKey<TrackProgressState> _progressKey = new GlobalKey();
  final GlobalKey<TrackControlState> _controlKey = new GlobalKey();
  final GlobalKey<TrackSliderState> _sliderKey = new GlobalKey();

  Color _gradientStart;
  AnimationController _animController;
  MediaRouteBloc _mediaRouteBloc;
  ImageProvider _imageProvider;
  bool _animForward = true;
  bool _isTicking = false;

  @override
  void initState() {
    super.initState();
    _animController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1250));
    _mediaRouteBloc = new MediaRouteBloc();

    if (_colorTween.begin == null) {
      _gradientStart = widget.baseColor;
      _colorTween.begin = _gradientStart;
      _colorTween.end = _gradientStart;
    }

    Future<PaletteGenerator> paletteFuture;
    final coverUrl = _manager.track.orElse(null)?.coverUrl;
    if (coverUrl != null) {
      final provider = CachedNetworkImageProvider(coverUrl);
      paletteFuture = PaletteGenerator.fromImageProvider(provider);
    }

    // Fade im images
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() => _isTicking = true);
      if (paletteFuture != null) {
        final palette = await paletteFuture;
        final paletteColor =
            (palette.vibrantColor ?? palette.dominantColor).color;
        _animateColor(paletteColor);
      }
    });
  }

  @override
  void dispose() {
    _mediaRouteBloc.close();
    _animController.dispose();
    super.dispose();
  }

  /*
   * PlaybackManager contract
   */

  Future<void> _notifyPlayingState() async {
    _progressKey.currentState?.onState();
    _controlKey.currentState?.rebuild();
    if (_manager.currPlayerState != SimplePlaybackState.BUFFERING) {
      Color color;
      if (_manager.track.isPresent && _imageProvider != null) {
        final palette =
            await PaletteGenerator.fromImageProvider(_imageProvider);
        color = (palette.vibrantColor ?? palette.dominantColor).color;
      } else {
        color = Theme.of(context).primaryColor;
      }
      _animateColor(color);
    }
  }

  @override
  void onEvent(PlaybackUIEvent event) {
    switch (event) {
      case PlaybackUIEvent.READY:
      case PlaybackUIEvent.REPEATING:
        _controlKey.currentState?.rebuild();
        break;
      case PlaybackUIEvent.SEEK:
        _sliderKey.currentState?.notifyTrackSeek();
        break;
      case PlaybackUIEvent.QUEUE:
        _barKey.currentState?.rebuild();
        _pageKey.currentState?.rebuild();
        _controlKey.currentState?.rebuild(); // shuffle state
        break;
      case PlaybackUIEvent.TRACK:
        _detailKey.currentState?.setTrack(_manager.track);
        _manager.track.ifPresent((track) async {
          _pageKey.currentState?.setTrack(_manager.track);
          _imageProvider = new CachedNetworkImageProvider(track.coverUrl);
        });
        break;
      case PlaybackUIEvent.PLAYER_STATE:
        _notifyPlayingState();
        break;
    }
  }

  /*
   * UI-Callbacks
   */

  Future<void> _onQueue() async {
    uiSub.pause();
    await Navigator.of(context)
        .push<void>(new MaterialPageRoute(builder: (context) {
      return new QueuePage();
    }));
    uiSub.resume();

    _pageKey.currentState?.setTrack(_manager.track);
    _detailKey.currentState?.setTrack(_manager.track);
  }

  void _onTrackChanged(PlaybackTrack nextTrack) {
    _detailKey.currentState?.setTrack(new Optional.of(nextTrack));
  }

  /*
   * Build
   */

  void _animateColor(Color changeColor) {
    if (_animForward) {
      _colorTween.begin = _gradientStart;
      _colorTween.end = changeColor;
      Future.delayed(_animDelay, _animController.forward);
    } else {
      _colorTween.end = _gradientStart;
      _colorTween.begin = changeColor;
      Future.delayed(_animDelay, _animController.reverse);
    }
    _gradientStart = changeColor;
    _animForward = !_animForward;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, kToolbarHeight),
        child: TrackAppBar(
          key: _barKey,
          colorTween: _colorTween,
          animController: _animController,
        ),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            flex: 20,
            child: Stack(
              children: <Widget>[
                TrackGradient(
                  colorTween: _colorTween,
                  canvasColor: Theme.of(context).canvasColor,
                  controller: _animController,
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isTicking ? 1.0 : 0.0,
                  child: TrackPages(
                      key: _pageKey, onTrackChanged: _onTrackChanged),
                ),
              ],
            ),
          ),
          TrackProgress(key: _progressKey),
          Flexible(
            flex: 4,
            child: TrackDetails(key: _detailKey),
          ),
          TrackSlider(
              padding: 20.0,
              delay: const Duration(milliseconds: 150),
              key: _sliderKey),
          Expanded(
            flex: 6,
            child: TrackControl(key: _controlKey),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        color: Theme.of(context).canvasColor,
        child: Container(
          height: kToolbarHeight,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CastButtonWidget(
                  bloc: _mediaRouteBloc,
                  tintColor: Colors.white70,
                  backgroundColor: Colors.transparent,
                ),
                Expanded(child: Container()),
                IconButton(
                  padding: const EdgeInsets.only(right: 5.0),
                  icon: Icon(Icons.format_list_bulleted),
                  onPressed: _onQueue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
