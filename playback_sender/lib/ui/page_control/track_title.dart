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

  Optional<PlaybackTrack> _track;

  @override
  void initState() {
    super.initState();
    _track = new PlaybackManager().track;
  }

  void setTrack(Optional<PlaybackTrack> track) {
    setState(() => _track = track);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            _track.orElse(_PLACEHOLDER_TRACK).title,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            _track.orElse(_PLACEHOLDER_TRACK).artist,
            textAlign: TextAlign.start,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
      ],
    );
  }
}
