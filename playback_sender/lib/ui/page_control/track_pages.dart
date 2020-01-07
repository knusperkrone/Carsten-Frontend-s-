part of 'control_page.dart';

typedef OnTrackChanged = void Function(PlaybackTrack nextTrack);

class TrackPages extends StatefulWidget {
  final OnTrackChanged onTrackChanged;

  const TrackPages({Key key, this.onTrackChanged}) : super(key: key);

  @override
  State createState() => new TrackPagesState();
}

class TrackPagesState extends TrackPageControllerState<TrackPages> {
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
    widget.onTrackChanged(track);
    if (next) {
      PlaybackManager().sendNext();
    } else {
      PlaybackManager().sendPrevious();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: buildPages(),
      onPageChanged: onScroll,
      physics: const BouncingScrollPhysics(),
    );
  }
}
