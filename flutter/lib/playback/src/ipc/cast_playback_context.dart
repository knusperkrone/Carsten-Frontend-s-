import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:playback_core/playback_core.dart';

import 'background_dispatcher.dart';
import 'foreground_dispatcher.dart';

class CastPlaybackContext {
  static const _CHANNEL_METHOD_NAME = 'interfaceag/cast_context_plugin';
  static const _EVENT_NAME = 'interfaceag/cast_context_plugin_event';
  static const _METHOD_CHANNEL = MethodChannel(_CHANNEL_METHOD_NAME);
  static const EVENT_CHANNEL = EventChannel(_EVENT_NAME);
  static bool _isInited = false;

  static Future<void> init() async {
    if (_isInited) {
      return;
    }

    // Start background service
    final handle = PluginUtilities.getCallbackHandle(backgroundDispatchEntry)!;
    while (true) {
      _isInited = (await _METHOD_CHANNEL
              .invokeMethod<bool>('init', <dynamic>[handle.toRawHandle()])) ??
          false;
      if (_isInited) {
        break;
      }
      print('Init failed, reattempting in 250ms');
      await new Future.delayed(const Duration(milliseconds: 250), () {});
    }
    foregroundDispatch();
  }

  static Future<double> setVolume(double volume) async {
    return _METHOD_CHANNEL.invokeMethod<double>('set_volume', <dynamic>[volume])
        as Future<double>;
  }

  static Future<double> volumeUp() async {
    return _METHOD_CHANNEL.invokeMethod<double>('volume_up', <dynamic>[])
        as Future<double>;
  }

  static Future<double> volumeDown() async {
    return _METHOD_CHANNEL.invokeMethod<double>('volume_down', <dynamic>[])
        as Future<double>;
  }

  Future<void> send(CastMessage message) async {
    final String msg = jsonEncode(message.toJson());
    final wasSend =
        await _METHOD_CHANNEL.invokeMethod<bool>('send_msg', <dynamic>[msg]);
    if (!(wasSend ?? false)) {
      print('[ERROR] Couldn\'t dispatch: send($msg)');
    }
  }

  Future<void> end() async {
    final wasSend =
        await _METHOD_CHANNEL.invokeMethod<bool>('end', <dynamic>[]);
    if (!(wasSend ?? false)) {
      print('[ERROR] Couldn\'t dispatch: end()');
    }
  }
}
