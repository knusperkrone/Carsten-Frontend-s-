part of 'control_page.dart';

typedef OnTrackChanged = void Function(PlaybackTrack nextTrack);

class TrackPages extends StatefulWidget {
  final OnTrackChanged onTrackChanged;

  const TrackPages({Key key, this.onTrackChanged}) : super(key: key);

  @override
  State createState() => new TrackPagesState();
}

class TrackPagesState extends TrackPageControllerState<TrackPages>
    with WidgetsBindingObserver {
  Timer _resumeTimeout;

  @override
  void initState() {
    super.initState();
    _resumeTimeout = new Timer(const Duration(milliseconds: 125), () {});
  }

  void setTrack(Optional<PlaybackTrack> track) {
    track.ifPresent((track) => animateToTrack(track));
  }

  @override
  Widget onPageBuild(BuildContext context, PlaybackTrack track) {
    final width = MediaQuery.of(context).size.width / 7;
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(width),
        child: CachedNetworkImage(
          imageUrl: track.coverUrl,
          width: 10,
          height: 10,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }

  @override
  void onUserScroll(PlaybackTrack track, bool next) {
    // This fires sometimes, even the user didn't touch the screen
    if (!_resumeTimeout.isActive) {
      widget.onTrackChanged(track);
      if (next) {
        PlaybackManager().sendNext();
      } else {
        PlaybackManager().sendPrevious();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resumeTimeout = new Timer(const Duration(milliseconds: 250), () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: trackCount,
      itemBuilder: buildPage,
      onPageChanged: onScroll,
      physics: const BouncingScrollPhysics(),
    );
  }
}
