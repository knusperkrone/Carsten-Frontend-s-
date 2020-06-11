import 'dart:convert';

import 'package:chrome_tube/playback/src/sender_playback_queue.dart';
import 'package:playback_interop/playback_interop.dart';

import 'ipc/cast_playback_context.dart';
import 'playback_listeners.dart';
import 'playback_receiver.dart';

class PlaybackManager extends PlaybackReceiver {
  /*
   * Singleton
   */

  static PlaybackManager _instance;

  factory PlaybackManager() {
    _instance ??= PlaybackManager._internal(new CastPlaybackContext());
    return _instance;
  }

  factory PlaybackManager.test(CastPlaybackContext mockedContext) {
    return PlaybackManager._internal(mockedContext);
  }

  PlaybackManager._internal(CastPlaybackContext cxt) : super.internal(cxt);

  /*
   * Wrap native calls
   */

  Future<void> init() async {
    return await CastPlaybackContext.init();
  }

  /*
   * IPC serialization
   */

  String serialize() => jsonEncode({
        'isConnected': isConnected,
        'trackSeek': trackSeek,
        'isRepeating': isRepeating,
        'currShuffleState': currShuffleState?.toJson(),
        'currPlayerState': currPlayerState.index,
        'seekTimestamp': seekTimestamp?.toIso8601String(),
        'queue': queue?.toJson(),
      });

  void deserialize(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    isConnected = json['isConnected'] as bool;
    trackSeek = json['trackSeek'] as double;
    isRepeating = json['isRepeating'] as bool;
    shuffleState = new ShuffleStateDto.fromJson(
        json['currShuffleState'] as Map<String, dynamic>);
    currPlayerState =
        SimplePlaybackState.values[json['currPlayerState'] as int];
    seekTimestamp = DateTime.parse(json['seekTimestamp'] as String);
    queue =
        new SenderPlaybackQueue.fromJson(json['queue'] as Map<String, dynamic>);
  }
}
