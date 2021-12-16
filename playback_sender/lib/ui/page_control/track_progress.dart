part of 'control_page.dart';

class TrackProgress extends StatefulWidget {
  const TrackProgress({required Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new TrackProgressState();
}

class TrackProgressState extends State<TrackProgress>
    with SingleTickerProviderStateMixin {
  final PlaybackManager _manager = new PlaybackManager();
  double _opacity = 0.0;

  void rebuild() {
    if (_manager.currPlayerState == SimplePlaybackState.BUFFERING) {
      setState(() {
        _opacity = 1.0; // Make non deterministic animation
      });
    } else {
      setState(() {
        _opacity = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 550),
      child: LinearProgressIndicator(
        color: Theme.of(context).colorScheme.secondary,
        value: null,
      ),
    );
  }
}
