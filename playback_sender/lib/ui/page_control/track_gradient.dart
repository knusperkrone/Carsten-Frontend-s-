import 'package:flutter/cupertino.dart';

class TrackGradient extends StatelessWidget {
  final ColorTween colorTween;
  final Color canvasColor;
  final AnimationController controller;

  const TrackGradient({
    @required this.colorTween,
    @required this.canvasColor,
    @required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [colorTween.animate(controller).value, canvasColor],
              ),
            ),
          );
        });
  }
}
