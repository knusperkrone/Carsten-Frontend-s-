import 'dart:math';

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:playback_interop/playback_interop.dart';

class TrackInfo extends StatefulWidget {
  final PlaybackTrack track;
  final double titleHeight;
  final TextStyle titleStyle;
  final double artistHeight;
  final TextStyle artistStyle;

  final double blank;
  final double velocity;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const TrackInfo({
    Key key,
    @required this.track,
    @required this.titleHeight,
    @required this.artistHeight,
    this.titleStyle,
    this.artistStyle,
    this.blank = 50,
    this.velocity = 30,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TrackInfoState();
}

class TrackInfoState extends State<TrackInfo> {
  PlaybackTrack _track;
  ScrollController _controller;
  final _trackKey = new GlobalKey<_TrackMarqueeState>();
  final _artistKey = new GlobalKey<_TrackMarqueeState>();

  void setTrack(PlaybackTrack track) {
    _track = track;
    _trackKey.currentState?.rebuild(TextSpan(
      text: _track.title,
      style: widget.titleStyle,
    ));
    _artistKey.currentState?.rebuild(TextSpan(
      text: _track.artist,
      style: widget.artistStyle,
    ));
  }

  @override
  void initState() {
    super.initState();
    _track = widget.track;
    _controller = new ScrollController();

    Future.delayed(const Duration(milliseconds: 500), () {
      Future.doWhile(() async {
        // ignore: invalid_use_of_protected_member
        if (_controller == null || _controller.positions.isEmpty) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        } else {
          // Tripped around
          _controller.jumpTo(0.0);

          final trackWidth = _trackKey.currentState._intrinsicTextWidth();
          final artistWidth = _artistKey.currentState._intrinsicTextWidth();

          final totalWidth = max(trackWidth, artistWidth) + widget.blank;
          final durationMs = (totalWidth / widget.velocity * 1000).toInt();
          final totalDuration = new Duration(milliseconds: durationMs);

          await _controller.animateTo(totalWidth,
              duration: totalDuration, curve: Curves.linear);
        }
        return mounted;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 10),
          height: widget.titleHeight,
          child: _TrackMarquee(
            key: _trackKey,
            controller: _controller,
            blank: widget.blank,
            span: TextSpan(
              text: _track.title,
              style: widget.titleStyle,
            ),
          ),
        ),
        Container(
          height: widget.artistHeight,
          child: _TrackMarquee(
            key: _artistKey,
            controller: _controller,
            blank: widget.blank,
            span: TextSpan(
              text: _track.artist,
              style: widget.artistStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackMarquee extends StatefulWidget {
  final TextSpan span;
  final double blank;
  final ScrollController controller;

  const _TrackMarquee({
    Key key,
    @required this.span,
    @required this.controller,
    this.blank = 50,
  }) : super(key: key);

  @override
  State createState() => new _TrackMarqueeState();
}

class _TrackMarqueeState extends State<_TrackMarquee> {
  TextSpan _span;
  double _textWidth;

  @override
  void initState() {
    super.initState();
    _span = widget.span;
  }

  void rebuild(TextSpan span) {
    if (span.text != _span.text) {
      setState(() {
        _textWidth = null;
        _span = span;
      });
    }
  }

  double _intrinsicTextWidth() {
    if (_textWidth == null) {
      final richTextWidget =
          Text.rich(_span, maxLines: 1).build(context) as RichText;
      final renderObject = richTextWidget.createRenderObject(context);
      const constraints = BoxConstraints(maxWidth: double.infinity);
      renderObject.layout(constraints);

      final boxes = renderObject.getBoxesForSelection(TextSelection(
        baseOffset: 0,
        extentOffset: _span.toPlainText().length,
      ));

      if (boxes.isEmpty) {
        _textWidth = 0;
      } else {
        _textWidth = boxes.last.right;
      }
    }
    return _textWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(builder: (context, constraints) {
        final _textWidth = _intrinsicTextWidth();
        final richTextWidget = Text.rich(_span, maxLines: 1).build(context);
        final blank = SizedBox(width: widget.blank);

        // Check if we need scrolling
        if (_textWidth < constraints.maxWidth) {
          return richTextWidget;
        }
        return FadingEdgeScrollView.fromScrollView(
          child: ListView.builder(
              controller: widget.controller,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => i % 2 == 0 ? richTextWidget : blank),
        );
      }),
    );
  }
}
