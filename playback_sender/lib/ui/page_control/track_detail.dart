part of 'control_page.dart';

class TrackDetails extends StatefulWidget {
  final double padding;

  const TrackDetails({Key key, @required this.padding}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TrackDetailsState();
}

class TrackDetailsState extends CachingState<TrackDetails> {
  final _infoKey = new GlobalKey<TrackInfoState>();
  PlaybackTrack _trackSentinel;

  Optional<PlaybackTrack> _track;

  @override
  void initState() {
    super.initState();
    _track = new PlaybackManager().track;
  }

  void setTrack(Optional<PlaybackTrack> track) {
    _infoKey.currentState?.setTrack(track.orElse(_trackSentinel));
  }

  @override
  Widget build(BuildContext context) {
    _trackSentinel ??= new PlaybackTrack.dummy(
      title: locale.translate('no_song_title'),
      artist: '',
    );

    return Container(
      padding: EdgeInsets.all(widget.padding),
      width: double.infinity,
      child: TrackInfo(
        key: _infoKey,
        track: _track.orElse(_trackSentinel),
        titleHeight: 35,
        artistHeight: 25,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        titleStyle: theme.textTheme.headline6,
        artistStyle: theme.textTheme.subtitle1,
        blank: 50,
      ),
    );
  }
}
