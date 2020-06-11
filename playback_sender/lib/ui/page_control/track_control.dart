part of 'control_page.dart';

class TrackControl extends StatefulWidget {
  const TrackControl({@required Key key}) : super(key: key);

  @override
  State createState() => new TrackControlState();
}

class TrackControlState extends State<TrackControl> {
  static const ICON_SIZE = 60.0;
  final PlaybackManager _manager = new PlaybackManager();

  void rebuild() => setState(() {});

  void _onShuffle() => _manager.sendShuffling(!_manager.isShuffled);

  void _onPrevious() => _manager.sendPrevious();

  void _onNext() => _manager.sendNext();

  void _onRepeat() => _manager.sendRepeating(!_manager.isRepeating);

  void _onPlayState() {
    if (_manager.currPlayerState == SimplePlaybackState.PAUSED) {
      _manager.sendPlay();
    } else if (_manager.currPlayerState == SimplePlaybackState.PLAYING) {
      _manager.sendPause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'controls',
      child: Material(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.shuffle),
              iconSize: ICON_SIZE - ICON_SIZE / 4,
              color: _manager.isShuffled ? Theme.of(context).accentColor : null,
              onPressed: _manager.isConnected ? _onShuffle : null,
            ),
            IconButton(
              icon: Icon(Icons.arrow_left),
              iconSize: ICON_SIZE,
              onPressed: _manager.isConnected ? _onPrevious : null,
            ),
            IconButton(
              icon: Icon(
                  _manager.currPlayerState == SimplePlaybackState.PAUSED ||
                          _manager.currPlayerState == SimplePlaybackState.ENDED
                      ? Icons.play_arrow
                      : Icons.pause),
              iconSize: ICON_SIZE,
              onPressed: _manager.isConnected ? _onPlayState : null,
            ),
            IconButton(
              icon: Icon(Icons.arrow_right),
              iconSize: ICON_SIZE,
              onPressed: _manager.isConnected ? _onNext : null,
            ),
            IconButton(
              icon: Icon(Icons.repeat),
              iconSize: ICON_SIZE - ICON_SIZE / 4,
              color:
                  _manager.isRepeating ? Theme.of(context).accentColor : null,
              onPressed: _manager.isConnected ? _onRepeat : null,
            ),
          ],
        ),
      ),
    );
  }
}
