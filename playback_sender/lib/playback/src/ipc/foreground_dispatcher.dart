import 'package:flutter/services.dart';
import 'package:playback_interop/playback_interop.dart';

import '../../playback.dart';
import 'ipc_constants.dart';
import 'message_dispatcher.dart';

/*
 * EntryPoint
 */
void foregroundDispatch() {
  final dispatcher = new ForegroundDispatcher();
  const channel = BasicMessageChannel<String>(
      NativeConstants.CHANNEL_MESSAGE_NAME, StringCodec());

  channel.setMessageHandler(dispatcher.dispatchMessage);
}

/*
 * Class implementation
 */
class ForegroundDispatcher extends MessageDispatcher {
  factory ForegroundDispatcher() {
    return new ForegroundDispatcher._internal(new PlaybackManager());
  }

  factory ForegroundDispatcher.test(PlaybackManager manager) {
    return new ForegroundDispatcher._internal(manager);
  }

  ForegroundDispatcher._internal(PlaybackManager manager) : super(manager);

  @override
  Future<CastMessage<String>> dispatchIPCMessage(CastMessage msg) async {
    switch (msg.type) {
      case NativeConstants.N_CONNECTED:
        // Nop
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
      case NativeConstants.N_FAILED:
      case NativeConstants.N_DISCONNECTED:
        manager.onConnect(new ReadyDto(false));
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
      case NativeConstants.N_SYNC:
        manager.deserialize(msg.data as String);
        return MessageDispatcher.IPC_MESSAGE_HANDLED;
    }
    return null;
  }

  @override
  String get tag => 'ForegroundDispatcher';
}
