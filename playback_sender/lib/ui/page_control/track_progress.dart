part of 'control_page.dart';

class TrackProgress extends StatefulWidget {
  const TrackProgress({@required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TrackProgressState();
}

class TrackProgressState extends State<TrackProgress>
    with SingleTickerProviderStateMixin {
  final PlaybackManager _manager = new PlaybackManager();
  double _val = 0.0;

  void onState() {
    if (_manager.currPlayerState == SimplePlaybackState.BUFFERING) {
      setState(() {
        _val = null; // Make non deterministic animation
      });
    } else {
      setState(() {
        _val = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: _val,
    );
  }
}
