part of 'dto.dart';

@JsonSerializable(createFactory: false, createToJson: false)
class TrackState {
  final String state;
  TrackState(this.state);
  const TrackState._internal(this.state);

  static const KICKOFF = TrackState._internal('KICKOFF');
  static const NEXT = TrackState._internal('NEXT');
  static const PREVIOUS = TrackState._internal('PREVIOUS');
  static const SYNC = TrackState._internal('SYNC');

  factory TrackState.fromJson(Map<String, dynamic> trackJson) {
    switch (trackJson['state'] as String) {
      case 'KICKOFF':
        return KICKOFF;
      case 'NEXT':
        return NEXT;
      case 'PREVIOUS':
        return PREVIOUS;
      case 'SYNC':
        return SYNC;
    }
    throw new StateError('[ERROR] Coulnd\'t parse trackState: $trackJson');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'state': state};
}

@JsonSerializable(createFactory: false, createToJson: false)
class PlayerState {
  final String state;
  PlayerState(this.state);
  const PlayerState._internal(this.state);

  static const UNKNOWN = PlayerState._internal('UNKNOWN');
  static const ENDED = PlayerState._internal('ENDED');
  static const PLAYING = PlayerState._internal('PLAYING');
  static const PAUSED = PlayerState._internal('PAUSED');
  static const BUFFERING = PlayerState._internal('BUFFERING');
  static const SEEKING = PlayerState._internal('SEEKING');

  factory PlayerState.fromJson(Map<String, dynamic> playerJson) {
    switch (playerJson['state'] as String) {
      case 'ENDED':
        return PlayerState.ENDED;
      case 'PLAYING':
        return PlayerState.PLAYING;
      case 'PAUSED':
        return PlayerState.PAUSED;
      case 'BUFFERING':
        return PlayerState.BUFFERING;
      case 'SEEKING':
        return PlayerState.SEEKING;
      default:
        print('[ERROR] Coulnd\'t parse playerState: $playerJson');
        return PlayerState.UNKNOWN;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'state': state};
}

@JsonSerializable(createFactory: false, createToJson: false)
class PlayerError {
  final String error;
  PlayerError(this.error);
  const PlayerError._internal(this.error);

  static const UNKNOWN = PlayerError._internal('UNKNOWN');
  static const HTML_5_PLAYER = PlayerError._internal('HTML_5_PLAYER');
  static const VIDEO_NOT_FOUND = PlayerError._internal('VIDEO_NOT_FOUND');
  static const INVALID_PARAMETER_IN_REQUEST = PlayerError._internal('INVALID_PARAMETER_IN_REQUEST');
  static const VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER = PlayerError._internal('VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER');

  factory PlayerError.fromJson(Map<String, dynamic> errorJson) {
    switch (errorJson['error'] as String) {
      case 'INVALID_PARAMETER_IN_REQUEST':
        return INVALID_PARAMETER_IN_REQUEST;
      case 'HTML_5_PLAYER':
        return HTML_5_PLAYER;
      case 'VIDEO_NOT_FOUND':
        return VIDEO_NOT_FOUND;
      case 'VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER1':
        return VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER;
      case 'VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER2':
        return VIDEO_NOT_PLAYABLE_IN_EMBEDDED_PLAYER;
      case 'UNKNOWN':
        return UNKNOWN;
      default:
        print('[ERROR] Couldn\'t parse error: $errorJson');
        return UNKNOWN;
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'error': error};
}
