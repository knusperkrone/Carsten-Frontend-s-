import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playback_interop/playback_interop.dart';

import '../../playback.dart';
import 'ipc_constants.dart';
import 'message_dispatcher.dart';
import 'notification.dart';

/*
 * EntryPoint
 */
@pragma('vm:entry-point')
void backgroundDispatchEntry() {
  WidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel(NativeConstants.CHANNEL_METHOD_NAME);
  const ipcChannel = BasicMessageChannel<dynamic>(NativeConstants.CHANNEL_MESSAGE_NAME, JSONMessageCodec());
  final dispatcher = new BackgroundDispatcher();
  final manager = new PlaybackManager();
  manager.isBackground = true;

  ipcChannel.setMessageHandler(dispatcher.dispatchMessage);
  methodChannel
      .invokeMethod<void>('background_isolate_inited', ['Mit einem Chromecast verbinden!']); // Native init cast_context
}

/*
 * Class implementation
 */
class BackgroundDispatcher extends MessageDispatcher {
  factory BackgroundDispatcher() {
    return new BackgroundDispatcher._internal(new PlaybackManager());
  }

  factory BackgroundDispatcher.test(PlaybackManager manager) {
    return new BackgroundDispatcher._internal(manager);
  }

  BackgroundDispatcher._internal(PlaybackManager manager) : super(manager);

  @override
  Future<CastMessage<String>> dispatchIPCMessage(CastMessage msg) async {
    switch (msg.type) {
      case NativeConstants.N_CONNECTING:
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
      case NativeConstants.N_CONNECTED:
        manager.scheduleFullSync();
        final ipcMsg = await TrackIndicatorNoti.withTrack(manager);
        if (ipcMsg != null) {
          return new CastMessage(NativeConstants.N_MSG_TRACK, ipcMsg);
        }
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
      case NativeConstants.N_DISCONNECTED:
      case NativeConstants.N_FAILED:
        manager.onConnect(new ReadyDto(false));
        return new CastMessage(NativeConstants.N_MSG_INFO, 'Mit einem Chromecast verbinden!');
      case NativeConstants.N_SYNC:
        return new CastMessage(NativeConstants.N_SYNC, manager.serialize());
      case NativeConstants.N_PB_TOGGLE:
        if (manager.currPlayerState == SimplePlaybackState.PLAYING) {
          manager.sendPause();
        } else {
          manager.sendPlay();
        }
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
      case NativeConstants.N_PB_NEXT:
        manager.sendNext();
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
      case NativeConstants.N_PB_PREV:
        manager.sendPrevious();
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
      case NativeConstants.N_PB_STOP:
        manager.sendStop();
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>> dispatchPlaybackMessage(CastMessage<String> msg) async {
    super.dispatchPlaybackMessage(msg);

    switch (msg.type) {
      case CafToSenderConstants.PB_READY:
      case CafToSenderConstants.PB_STATE_CHANGED:
      case CafToSenderConstants.PB_TRACK:
      case CafToSenderConstants.PB_QUEUE:
        final msg = await TrackIndicatorNoti.withTrack(manager);
        if (msg != null) {
          return new CastMessage(NativeConstants.N_MSG_TRACK, msg).toJson();
        }
    }
    return null;
  }

  @override
  String get tag => 'BackgroundDispatcher';
}
