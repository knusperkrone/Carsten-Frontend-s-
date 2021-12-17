import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:playback_core/playback_core.dart';

import '../../playback.dart';

abstract class MessageDispatcher {
  @protected
  // ignore: non_constant_identifier_names
  static final CastMessage<String> IPC_MESSAGE_HANDLED =
      new CastMessage('', '');

  @protected
  final PlaybackManager manager;

  MessageDispatcher(this.manager);

  /*
   * Template methods
   */

  @protected
  Future<CastMessage<String>?> dispatchIPCMessage(CastMessage msg);

  @protected
  String get tag;

  /*
   * Business methods
   */

  Future<Map<String, dynamic>?> dispatchMessage(dynamic sourceMsg) async {
    final msg = new CastMessage<String>.fromJson(sourceMsg as Map<String, dynamic>);

    final ipcResponse = await dispatchIPCMessage(msg);
    if (ipcResponse != null) {
      if (ipcResponse == IPC_MESSAGE_HANDLED) {
        return null;
      }
      return ipcResponse.toJson();
    }
    dispatchPlaybackMessage(msg);
    return null;
  }

  @protected
  void dispatchPlaybackMessage(CastMessage<String> msg) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(msg.data) as Map<String, dynamic>;
    } catch (e) {
      print("Coulnd't parse ${msg.type} - ${msg.data}");
      return;
    }

    switch (msg.type) {
      case CafToSenderConstants.PB_READY:
        manager.onConnect(new ReadyDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_STATE_CHANGED:
        manager.onPlayerState(new PlayerStateDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_ERROR:
        manager.onError(new ErrorDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_SEEK:
        manager.onTrackSeek(new SeekDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_SHUFFLING:
        manager.onShuffling(new ShuffleStateDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_REPEATING:
        manager.onRepeating(new RepeatingDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_TRACK:
        manager.onTrackState(new TrackStateDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_QUEUE:
        manager.onQueue(new PlaybackQueueDto.fromJson(
            jsonDecode(msg.data) as Map<String, dynamic>));
        break;
      case CafToSenderConstants.PB_DELTA_ADD:
        manager.onAddPrioDelta(new AddPrioDeltaDto.fromJson(json));
        break;
      case CafToSenderConstants.PB_DELTA_MOVE:
        manager.onMovePrioDelta(new MovePrioDeltaDto.fromJson(json));
        break;
      default:
        print('[ERROR][$tag] Invalid message:\n${msg.toJson()}');
    }
  }
}
