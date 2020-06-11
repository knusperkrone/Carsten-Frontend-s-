import 'package:flutter/material.dart';

class TrackGradient extends AnimatedWidget {
  final ColorTween colorTween;
  final Color canvasColor;

  AnimationController get _progress => listenable as AnimationController;

  const TrackGradient({
    @required this.colorTween,
    @required this.canvasColor,
    @required AnimationController controller,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorTween.animate(_progress).value, canvasColor],
        ),
      ),
    );
  }
}
