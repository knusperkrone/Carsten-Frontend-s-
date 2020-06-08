import 'dart:html';

import 'package:playback_caf_dart/playback_caf.dart';
import 'package:playback_interop/playback_interop.dart';

import 'cast.dart';
import 'transformer.dart';

class CastMessageDispatcher {
  final PlaybackManager _manager;

  CastMessageDispatcher(this._manager);

  void onMessage(CastReceiveMessage message) {
    window.console.dir(message);
    final msg = message.data;

    switch (msg.type) {
      case SenderToCafConstants.PB_PLAY:
        _manager.play();
        break;
      case SenderToCafConstants.PB_PAUSE:
        _manager.pause();
        break;
      case SenderToCafConstants.PB_PLAY_TRACK:
        final PlaybackTrack transformed = Transformer.transformTrack(msg.data);
        _manager.playTrack(transformed);
        break;
      case SenderToCafConstants.PB_SEEK_TO:
        _manager.setSeek(msg.data as int);
        break;
      case SenderToCafConstants.PB_PREV_TRACK:
        _manager.playPrevious();
        break;
      case SenderToCafConstants.PB_NEXT_TRACK:
        _manager.playNext();
        break;
      case SenderToCafConstants.PB_SHUFFLING:
        _manager.setShuffling(msg.data as bool);
        break;
      case SenderToCafConstants.PB_REPEATING:
        _manager.setRepeating(msg.data as bool);
        break;
      case SenderToCafConstants.PB_STOP:
        _manager.stop();
        break;
      case SenderToCafConstants.PB_APPEND_TO_QUEUE:
        final List<PlaybackTrack> transformed = Transformer.transfromTracks(msg.data as List<dynamic>);
        _manager.appendToQueue(transformed);
        break;
      case SenderToCafConstants.PB_CLEAR_QUEUE:
        _manager.startNewQueue();
        break;
      case SenderToCafConstants.PB_SCHEDULE_SYNC:
        _manager.syncAll();
        break;
      case SenderToCafConstants.PB_APPEND_TO_PRIO:
        final PlaybackTrack transformed = Transformer.transformTrack(msg.data);
        _manager.appendToPrio(transformed);
        break;
      case SenderToCafConstants.PB_MOVE:
        _manager.move(msg.data[0] as bool, msg.data[1] as int, msg.data[2] as bool, msg.data[3] as int);
        break;
      default:
        print('[ERROR] Invalid command! ${msg.type}');
    }
    print('done!');
  }
}
