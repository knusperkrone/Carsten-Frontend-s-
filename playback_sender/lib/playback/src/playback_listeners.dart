enum SimplePlaybackState { PLAYING, PAUSED, BUFFERING, ENDED }

abstract class PlaybackUIListener {
  void notifyPlaybackReady();

  void notifyTrack();

  void notifyQueue();

  void notifyPlayingState();

  void notifyTrackSeek();

  void notifyRepeating();
}
