import 'package:chrome_tube/playback/playback.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:playback_core/playback_core.dart';

abstract class TrackPageControllerState<T extends StatefulWidget>
    extends State<T> {
  static const _TRANSITION_DURATION = Duration(milliseconds: 500);
  static const _LIST_EQUALITY = ListEquality<PlaybackTrack>();

  @protected
  late PageController pageController;
  @protected
  final PlaybackManager manager = new PlaybackManager();

  bool _isAnimating = false;
  late int _currIndex;
  late List<PlaybackTrack> _shadowTracks;

  void onUserScroll(PlaybackTrack track, bool next);

  Widget onPageBuild(BuildContext context, PlaybackTrack track);

  @override
  void initState() {
    super.initState();
    if (manager.track == null) {
      _shadowTracks = [];
      _currIndex = 0;
    } else {
      _shadowTracks = _stackAllTracks();
      _currIndex =
          _shadowTracks.indexWhere((t) => t.title == manager.track!.title);
    }
    pageController = PageController(initialPage: _currIndex);
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void rebuild() {
    setState(() {
      if (manager.track != null) {
        animateToTrack(manager.track!);
      }
    });
  }

  @protected
  Widget buildPage(BuildContext context, int i) {
    if (hasNoTracks) {
      final size = MediaQuery.of(context).size.height / 3;
      return Icon(Icons.all_out, size: size); // Default icon
    }
    return onPageBuild(context, _shadowTracks[i]);
  }

  @protected
  void onScroll(int newIndex) {
    if (manager.track != null) {
      final oldIndex = _currIndex;
      if (mounted &&
          oldIndex != newIndex &&
          pageController.page != manager.track!.queueIndex) {
        _currIndex = newIndex;

        if (!_isAnimating) {
          onUserScroll(_shadowTracks[newIndex], oldIndex < newIndex);
        }
      }
    }
  }

  Future<void> animateToTrack(PlaybackTrack track) async {
    final tmpTracks = _stackAllTracks();
    _currIndex = tmpTracks.indexWhere((t) => t.title == track.title);

    _isAnimating = true;
    if (_LIST_EQUALITY.equals(_shadowTracks, tmpTracks)) {
      await pageController.animateToPage(_currIndex,
          duration: _TRANSITION_DURATION, curve: Curves.linear);
    } else {
      pageController.jumpToPage(_currIndex);
      setState(() {
        _shadowTracks = tmpTracks;
      });
    }
    _isAnimating = false;
  }

  PlaybackTrack? get showTrack {
    if (manager.track!.queueIndex == _currIndex) {
      return manager.track!;
    }
    return _shadowTracks[_currIndex];
  }

  List<PlaybackTrack> _stackAllTracks() {
    final allTracks = <PlaybackTrack>[];
    final currentIndex = manager.trackIndex;
    final before = manager.queueTracks.sublist(0, currentIndex + 1);
    final after = manager.queueTracks.sublist(currentIndex + 1);

    allTracks.addAll(before);
    if (manager.track!.isPrio) {
      allTracks.add(manager.track!);
    }
    allTracks.addAll(manager.prioTracks);
    allTracks.addAll(after);
    return allTracks;
  }

  int get trackCount {
    if (hasNoTracks) {
      return 1;
    }
    final currentIndex = manager.trackIndex;
    int count = currentIndex;
    count += manager.queueTracks.length - currentIndex;
    if (manager.track!.isPrio) {
      count += 1;
    }
    count += manager.prioTracks.length;

    return count;
  }

  bool get hasNoTracks =>
      manager.prioTracks.isEmpty && manager.queueTracks.isEmpty;
}
