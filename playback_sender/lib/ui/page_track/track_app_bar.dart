import 'dart:math';

import 'package:flutter/material.dart';

class TrackPageAppBar extends SliverPersistentHeaderDelegate {
  static const SHUFFLE_SIZE = 35.0;

  final double expandedHeight;
  final String name;
  final String owner;
  final ImageProvider imageProvider;
  final Color gradientColor;
  final double textSize;
  final VoidCallback onShuffle;
  final String text;

  const TrackPageAppBar({
    @required this.expandedHeight,
    @required this.textSize,
    @required this.text,
    @required this.name,
    @required this.owner,
    @required this.imageProvider,
    @required this.gradientColor,
    @required this.onShuffle,
  });

  /*
   * Build
   */

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final qWidth = MediaQuery.of(context).size.width;

    final Color gradientVal = gradientColor ?? theme.primaryColor;
    final double colorRelation = min(0.2, shrinkOffset / expandedHeight);
    final Color gradientStart = new Color.fromARGB(
      255,
      max(0, gradientVal.red - (gradientVal.red * colorRelation).toInt()),
      max(0, gradientVal.green - (gradientVal.green * colorRelation).toInt()),
      max(0, gradientVal.blue - (gradientVal.blue * colorRelation).toInt()),
    );

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.8, 0.8],
              colors: [gradientStart, theme.canvasColor, Colors.transparent],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: kToolbarHeight / 2 + shrinkOffset / 4),
          child: Opacity(
            opacity: max(0, 1 - (shrinkOffset / expandedHeight) * 2),
            child: Column(
              children: <Widget>[
                Image(
                  image: imageProvider,
                  fit: BoxFit.fitHeight,
                  width: qWidth - qWidth / 4 - shrinkOffset,
                  height: expandedHeight -
                      kToolbarHeight -
                      shrinkOffset -
                      40.0 -
                      SHUFFLE_SIZE,
                ),
                Container(
                  padding: const EdgeInsets.only(top: 12.0),
                  height:
                      textSize - (shrinkOffset / expandedHeight) * textSize + 6,
                  child: owner == null
                      ? Container()
                      : Container(
                          decoration: const BoxDecoration(
                            color: Colors.black12,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            owner,
                            style: theme.textTheme.subtitle1
                                .copyWith(color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: kToolbarHeight / 4,
          child: Container(
            width: qWidth,
            child: Opacity(
              opacity: shrinkOffset / expandedHeight,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headline6.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: max(minExtent - 10.0 - SHUFFLE_SIZE,
              expandedHeight - 10.0 - SHUFFLE_SIZE - shrinkOffset),
          left: qWidth / 8,
          right: qWidth / 8,
          child: ElevatedButton(
            onPressed: onShuffle,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(theme.accentColor),
              elevation: MaterialStateProperty.all(5.0),
            ),
            child: SizedBox(
              height: 47.0,
              width: qWidth / 1.5,
              child: Center(
                child: Text(text),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white70,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + SHUFFLE_SIZE;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is TrackPageAppBar) {
      return text != oldDelegate.text;
    }
    return false;
  }
}
