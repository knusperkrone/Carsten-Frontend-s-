part of 'control_page.dart';

class TrackDetails extends StatefulWidget {
  const TrackDetails({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TrackDetailsState();
}

class TrackDetailsState extends State<TrackDetails> {
  // ignore: non_constant_identifier_names
  static final _PLACEHOLDER_TRACK =
      new PlaybackTrack.dummy(title: 'No Song', artist: '');
  final _infoKey = new GlobalKey<TrackInfoState>();

  Optional<PlaybackTrack> _track;

  @override
  void initState() {
    super.initState();
    _track = new PlaybackManager().track;
  }

  void setTrack(Optional<PlaybackTrack> track) {
    _infoKey.currentState?.setTrack(track.orElse(_PLACEHOLDER_TRACK));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: TrackInfo(
        key: _infoKey,
        track: _track.orElse(_PLACEHOLDER_TRACK),
        titleHeight: 35,
        artistHeight: 25,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        titleStyle: Theme.of(context).textTheme.headline6,
        artistStyle: Theme.of(context).textTheme.subtitle1,
        blank: 50,
      ),
    );
  }
}
