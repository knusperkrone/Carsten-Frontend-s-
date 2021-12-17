const String CHANNEL_NAMESPACE = 'urn:x-cast:com.pierfrancescosoffritti.androidyoutubeplayer.chromecast.communication';

class CafToSenderConstants {
  static const YT_READY = 'YT_READY';

  static const PB_READY = 'PB_READY';
  static const PB_STATE_CHANGED = 'PB_STATE_CHANGED';
  static const PB_SEEK = 'PB_SEEK';
  static const PB_SHUFFLING = 'PB_SHUFFLING';
  static const PB_REPEATING = 'PB_REPEATING';
  static const PB_ERROR = 'PB_ERROR';
  static const PB_TRACK = 'PB_TRACK';
  static const PB_QUEUE = 'PB_QUEUE';

  static const PB_DELTA_ADD = 'PB_DELTA_ADD';
  static const PB_DELTA_MOVE = 'PB_DELTA_MOVE';
}

class SenderToCafConstants {
  static const PB_PLAY = 'PB_PLAY';
  static const PB_PAUSE = 'PB_PAUSE';
  static const PB_PLAY_TRACK = 'PB_PLAY_TRACK';
  static const PB_SEEK_TO = 'PB_SEEK_TO';
  static const PB_PREV_TRACK = 'PB_PREV_TRACK';
  static const PB_NEXT_TRACK = 'PB_NEXT_TRACK';
  static const PB_SHUFFLING = 'PB_SHUFFLING';
  static const PB_REPEATING = 'PB_REPEATING';
  static const PB_STOP = 'PB_STOP';

  static const PB_APPEND_TO_QUEUE = 'PB_APPEND_TO_QUEUE';
  static const PB_CLEAR_QUEUE = 'PB_CLEAR_QUEUE';

  static const PB_APPEND_TO_PRIO = 'PB_APPEND_TO_PRIO';
  static const PB_MOVE = 'PB_MOVE';

  static const PB_SCHEDULE_SYNC = 'PB_SCHEDULE_SYNC';
}
