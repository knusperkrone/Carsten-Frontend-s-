import 'package:dcache/dcache.dart';
import 'package:meta/meta.dart';
import 'package:playback_interop/playback_interop.dart';

abstract class PlaybackPlayer {
  void play();
  void pause();
  void stop();
  int? getTimeInMs();
  void seekTo(int seekMs);
  void playTrack(PlaybackTrack track);
  Future<String>? cacheVideoKey(PlaybackTrack track);

  static final Cache<String, String> _cache = new SimpleCache<String, String>(storage: InMemoryStorage(1024));

  @protected
  Cache<String, String> get cache => PlaybackPlayer._cache;
}
