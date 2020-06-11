import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:playback_interop/playback_interop.dart';

import 'background_dispatcher.dart';
import 'foreground_dispatcher.dart';

class CastPlaybackContext {
  static const _CHANNEL_METHOD_NAME = 'interfaceag/cast_context_plugin';
  static const _METHOD_CHANNEL = MethodChannel(_CHANNEL_METHOD_NAME);
  static bool _isInited = false;

  static Future<void> init() async {
    if (_isInited) {
      return;
    }

    // Start background service
    final handle = PluginUtilities.getCallbackHandle(backgroundDispatchEntry);
    while (true) {
      _isInited = await _METHOD_CHANNEL
          .invokeMethod('init', <dynamic>[handle.toRawHandle()]);
      if (_isInited) {
        break;
      }
      await new Future.delayed(const Duration(milliseconds: 250), () {});
    }
    foregroundDispatch();
  }

  Future<void> send(CastMessage message) async {
    final String msg = jsonEncode(message.toJson());
    final wasSend =
        await _METHOD_CHANNEL.invokeMethod<bool>('send_msg', <dynamic>[msg]);
    if (!wasSend) {
      print('[ERROR] Couldn\'t dispatch: send($msg)');
    }
  }

  Future<void> end() async {
    final wasSend =
        await _METHOD_CHANNEL.invokeMethod<bool>('end', <dynamic>[]);
    if (!wasSend) {
      print('[ERROR] Couldn\'t dispatch: end()');
    }
  }
}
