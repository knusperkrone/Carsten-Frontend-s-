import 'package:chrome_tube/playback/playback.dart';
import 'package:flutter/material.dart';

class TrackAppBar extends StatefulWidget {
  final ColorTween colorTween;
  final AnimationController animController;

  const TrackAppBar(
      {Key? key, required this.colorTween, required this.animController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new TrackAppBarState();
}

class TrackAppBarState extends State<TrackAppBar> {
  final PlaybackManager _manager = new PlaybackManager();

  void rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animController,
      child: Text(_manager.playlistName),
      builder: (context, child) {
        return AppBar(
          elevation: 0.0,
          title: child,
          backgroundColor:
              widget.colorTween.animate(widget.animController).value,
        );
      },
    );
  }
}
