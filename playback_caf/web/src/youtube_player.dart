import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:playback_caf_dart/playback_caf.dart';
import 'package:playback_interop/playback_interop.dart';

import 'youtube_iframe.dart' as yt;

class YoutubePlayer extends PlaybackPlayer {
  static const MS_FACTOR = 1000;
  static const SEEK_TICK_INTERVAL_MS = 1000 * 10;

  final PlaybackManager _manager;
  StreamSubscription _periodicSeekDispatcher; // Null safe by optional
  PlaybackTrack _currTrack; // Null safe by assert
  yt.Player _iplayer; // null safe
  int _seekMs = 0;

  bool _isCueing = false;

  YoutubePlayer(this._manager) : assert(_manager != null) {
    _iplayer = new yt.Player(
      'youTubePlayerDOM',
      yt.PlayerOptions(
        height: '98%',
        width: '98%',
        events: yt.PlayerEvents(
          onReady: _onReady,
          onError: (e) => _onError(e.data),
          onStateChange: (e) => _sendPlayerStateChange(e.data),
        ),
        playerVars: yt.PlayerVars(
            // autoplay: 0,
            autohide: 1,
            controls: 0,
            enablejsapi: 1,
            fs: 0,
            // origin: 'https://www.youtube.com',
            rel: 0,
            showinfo: 0,
            iv_load_policy: 3),
      ),
    );
  }

  @override
  void play() => _iplayer.playVideo();

  @override
  void pause() => _iplayer.pauseVideo();

  @override
  void stop() => _iplayer.stop();

  @override
  void seekTo(int seekMs) {
    _periodicSeekDispatcher?.cancel();
    _manager.onTrackSeek(seekMs);
    _iplayer.seekTo(seekMs / MS_FACTOR, true);
  }

  @override
  Future<void> playTrack(PlaybackTrack track) async {
    assert(track != null);
    _isCueing = true;
    _currTrack = track;
    final id = await cacheVideoKey(track);
    _iplayer.loadVideoById(id, 0.0);
  }

  @override
  int getTimeInMs() {
    _seekMs = ((_iplayer.getCurrentTime() ?? 0) * MS_FACTOR).toInt();
    if (_seekMs.isNaN) {
      _seekMs = 0;
    }
    return _seekMs;
  }

  /*
   * Helpers
   */

  @override
  Future<String> cacheVideoKey(PlaybackTrack track) async {
    final key = '${track.title} ${track.artist}';
    String id = cache.get(key);
    if (id == null) {
      try {
        final uri = Uri.http(
          'spotitube.if-lab.de',
          '/api/youtube/search',
          {'q': '${track.title} ${track.artist}'},
        );
        final resp = await http.get(uri);

        if (resp.statusCode != 200) {
          throw new StateError('Invalid status code: ${resp.statusCode}\n${resp.body}');
        }
        id = jsonDecode(resp.body)['id'] as String;
        if (id == null) {
          throw new StateError('Invalid id with request ${resp.statusCode}\n${resp.body}');
        }

        cache.set(key, id);
      } catch (e) {
        print('[ERROR] couldn\'t get Video id: $id\n$e');
      }
    }
    return id ?? 'QryoOF5jEbc'; // Fallback is twerk
  }

  /*
   * Lifecycle callbacks
   */

  void _seekListener(dynamic _) {
    final seekMs = getTimeInMs();
    _manager.onTrackSeek(seekMs);
  }

  void _onReady() {
    _manager.onPlayerReady(this);
  }

  void _onError(int error) {
    print('[ERROR] lib_yt onError: $error');
    _manager.onError('YT errorCode: $error');
  }

  void _sendPlayerStateChange(int playerState) {
    assert(_currTrack != null);
    _periodicSeekDispatcher?.cancel();

    switch (playerState) {
      case yt.PlayerState.PLAYING:
        _currTrack.durationMs = (_iplayer.getDuration() * MS_FACTOR).toInt();

        _manager.onPlayerStateChanged(PlayerState.PLAYING);
        _periodicSeekDispatcher =
            Stream<dynamic>.periodic(const Duration(milliseconds: SEEK_TICK_INTERVAL_MS)).listen(_seekListener);
        break;
      case yt.PlayerState.PAUSED:
        if (_isCueing == false) {
          _manager.onPlayerStateChanged(PlayerState.PAUSED);
        }
        break;
      case yt.PlayerState.ENDED:
        _manager.onPlayerStateChanged(PlayerState.ENDED);
        break;
      case yt.PlayerState.BUFFERING:
      case yt.PlayerState.UNSTARTED:
      case yt.PlayerState.CUED:
        _manager.onPlayerStateChanged(PlayerState.BUFFERING);
        break;
      default:
        print('[ERROR] Invalid yt player state: $playerState');
    }
    _isCueing = false;
  }
}
