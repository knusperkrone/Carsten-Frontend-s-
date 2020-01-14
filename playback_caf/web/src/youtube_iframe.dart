@JS('YT')
library yt;

import 'package:js/js.dart';

typedef OnReadyCallback = void Function();
typedef OnStateCallback = void Function(CallbackEvent event);
typedef OnErrorCallback = void Function(CallbackEvent event);

@JS()
class Player {
  external Player(String id, PlayerOptions options);

  external void playVideo();
  external void pauseVideo();
  external void stop();
  external void seekTo(num seek, bool alwaysTrue);
  external void cueVideoById(String id, double seek);
  external void loadVideoById(String id, double seek);
  external double getCurrentTime();
  external double getDuration();
}

@JS()
class CallbackEvent {
  external int get data;
}

class PlayerState {
  static const int UNSTARTED = -1;
  static const int ENDED = 0;
  static const int PLAYING = 1;
  static const int PAUSED = 2;
  static const int BUFFERING = 3;
  static const int CUED = 5;
}

@JS()
@anonymous
class PlayerEvents {
  external factory PlayerEvents({
    OnReadyCallback onReady,
    OnStateCallback onStateChange,
    OnErrorCallback onError,
  });
}

@JS()
@anonymous
class PlayerVars {
  external factory PlayerVars({
    int autoplay,
    int autohide,
    int controls,
    int enablejsapi,
    int fs,
    String origin,
    int rel,
    int showinfo,
    // ignore: non_constant_identifier_names
    int iv_load_policy,
  });
}

@JS()
@anonymous
class PlayerOptions {
  external factory PlayerOptions({
    String height,
    String width,
    PlayerEvents events,
    PlayerVars playerVars,
  });
}
