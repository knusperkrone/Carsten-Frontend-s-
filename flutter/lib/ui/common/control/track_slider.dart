import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/common/state.dart';
import 'package:flutter/material.dart';

class LinearTrackSlider extends StatefulWidget {
  final double padding;
  final Duration delay;

  const LinearTrackSlider({
    Key? key,
    this.delay = const Duration(milliseconds: 0),
    required this.padding,
  }) : super(key: key);

  @override
  State createState() => new LinearTrackSliderState();
}

class TrackSlider extends LinearTrackSlider {
  const TrackSlider({
    Key? key,
    Duration delay = const Duration(milliseconds: 0),
    required double padding,
  }) : super(key: key, padding: padding, delay: delay);

  @override
  State createState() => new TrackSliderState();
}

class LinearTrackSliderState extends UIListenerState<LinearTrackSlider>
    with TickerProviderStateMixin {
  final PlaybackManager _manager = new PlaybackManager();

  final _animTween = new Tween<double>(begin: 0.0, end: 0.0);
  late AnimationController _animController;
  SimplePlaybackState lastState = SimplePlaybackState.ENDED;
  double? _trackDuration;

  @override
  void initState() {
    super.initState();
    _animController = new AnimationController(vsync: this);
    Future.delayed(widget.delay, _doSeekInterpolation);
  }

  /*
   * PlaybackTrackUIListener contract
   */

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void onEvent(PlaybackUIEvent event) {
    switch (event) {
      case PlaybackUIEvent.TRACK:
      case PlaybackUIEvent.PLAYER_STATE:
      case PlaybackUIEvent.SEEK:
        _doSeekInterpolation();
        break;
      default:
    }
  }

  /*
   * Build
   */

  void _doSeekInterpolation() {
    final track = _manager.track;
    if (track != null) {
      if (track.durationMs == null) {
        setState(() {
          _trackDuration = 0.1;
          _animController.value = 0.0;
          _animController.stop(canceled: true);
        });
        return;
      }

      _trackDuration = track.durationMs!.toDouble();
      _animTween.end = _trackDuration;
      _animController.duration =
          Duration(milliseconds: _trackDuration!.toInt());

      double timeDelta = _trackDuration! - _manager.trackSeek;
      if (_manager.currPlayerState == SimplePlaybackState.PLAYING) {
        timeDelta -=
            _manager.seekTimestamp.difference(DateTime.now()).inMilliseconds;
      }
      _animController.value = 1 - timeDelta / _trackDuration!;

      if (_manager.currPlayerState == SimplePlaybackState.PLAYING) {
        _animController.forward();
      } else {
        _animController.stop();
      }
      if (mounted) {
        setState(() {});
      }
    } else {
      _trackDuration = 0.0;
      _animController.value = 0.0;
      _animController.stop(canceled: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      animation: _animController,
      builder: (context, _) => new LinearProgressIndicator(
        value: _animController.value,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}

class TrackSliderState extends LinearTrackSliderState {
  bool _isUser = false;
  double _userVal = 0.0;

  /*
   * UI-Callbacks
   */

  void _onChangeStart(double startValue) => setState(() {
        _isUser = true;
        _userVal = startValue;
      });

  void _onChanged(double value) => setState(() => _userVal = value);

  void _onChangeEnd(double endValue) {
    if (_manager.track != null) {
      _manager.sendSeek(endValue.round());
    }
  }

  /*
   * UiListener contract
   */

  @override
  void onEvent(PlaybackUIEvent event) {
    if (event == PlaybackUIEvent.SEEK) {
      setState(() => _isUser = false);
    }
    super.onEvent(event);
  }

  /*
   * Build
   */

  String _formatTime(double? timeMs) {
    if (timeMs == null) {
      return '00:00';
    }
    String pad(num n) => "${n < 10.0 ? "0" : ""}${n.toInt()}";
    return '${pad((timeMs ~/ 1000) ~/ 60)}:${pad((timeMs ~/ 1000) % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final timeStamp =
            _isUser ? _userVal : _animTween.animate(_animController).value;
        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.padding),
              child: Row(
                children: <Widget>[
                  Text(_formatTime(timeStamp)),
                  Expanded(child: Container()),
                  Text(_formatTime(_trackDuration)),
                ],
              ),
            ),
            Slider(
              value: timeStamp,
              max: _trackDuration ?? 0xfffffffff,
              onChangeStart: _onChangeStart,
              onChanged: _onChanged,
              onChangeEnd: _onChangeEnd,
            ),
          ],
        );
      },
    );
  }
}
