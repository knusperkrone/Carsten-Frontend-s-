import 'package:chrome_tube/playback/playback.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:playback_interop/playback_interop.dart';

abstract class TrackPageControllerState<T extends StatefulWidget>
    extends State<T> {
  static const _TRANSITION_DURATION = Duration(milliseconds: 500);
  static const _LIST_EQUALITY = ListEquality<PlaybackTrack>();

  @protected
  PageController pageController;
  @protected
  final PlaybackManager manager = new PlaybackManager();

  int _currIndex;
  bool _isAnimating = false;
  List<PlaybackTrack> _shadowTracks;

  void onUserScroll(PlaybackTrack track, bool next);

  Widget onPageBuild(BuildContext context, PlaybackTrack track);

  @override
  void initState() {
    super.initState();
    if (!manager.track.isPresent) {
      _shadowTracks = [];
      _currIndex = 0;
    } else {
      _shadowTracks = _stackAllTracks();
      _currIndex =
          _shadowTracks.indexWhere((t) => t.title == manager.track.value.title);
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
      if (manager.track.isPresent) {
        animateToTrack(manager.track.value);
      }
    });
  }

  @protected
  List<Widget> buildPages() {
    if (hasNoTracks) {
      return [Icon(Icons.all_out, size: 250)]; // Default icon
    }
    return _shadowTracks.map((t) => onPageBuild(context, t)).toList();
  }

  @protected
  void onScroll(int newIndex) {
    manager.track.ifPresent((track) {
      final oldIndex = _currIndex;
      if (mounted &&
          oldIndex != newIndex &&
          pageController.page != track.queueIndex) {
        _currIndex = newIndex;

        if (!_isAnimating) {
          onUserScroll(_shadowTracks[newIndex], oldIndex < newIndex);
        }
      }
    });
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

  PlaybackTrack get showTrack {
    assert(manager.track.isPresent);
    if (manager.track == null) {
      return null;
    } else if (manager.track.value.queueIndex == _currIndex) {
      return manager.track.value;
    }
    return _shadowTracks[_currIndex];
  }

  List<PlaybackTrack> _stackAllTracks() {
    assert(manager.track.isPresent);
    final allTracks = <PlaybackTrack>[];
    final currentIndex = manager.trackIndex ?? 0;
    final before = manager.queueTracks.sublist(0, currentIndex + 1);
    final after = manager.queueTracks.sublist(currentIndex + 1);

    allTracks.addAll(before);
    if (manager.track.value.isPrio) {
      allTracks.add(manager.track.value);
    }
    allTracks.addAll(manager.prioTracks);
    allTracks.addAll(after);
    return allTracks;
  }

  bool get hasNoTracks =>
      manager.prioTracks.isEmpty && manager.queueTracks.isEmpty;
}
