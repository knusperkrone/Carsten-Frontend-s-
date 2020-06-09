import 'dart:async';

import 'package:flutter/services.dart';

class FlutterGoogleCastButton {
  static const MethodChannel _channel =
    const MethodChannel('flutter_google_cast_button');

  static Future<void> loadMedia(String url) async =>
    await _channel.invokeMethod('loadMedia', <String, dynamic>{
      'url': url,
      });

  static Future<void> showCastDialog() async =>
    await _channel.invokeMethod('showCastDialog');

  static const EventChannel _castEventChannel =
    const EventChannel('cast_state_event');

  static Stream<dynamic> castEventStream() =>
    _castEventChannel.receiveBroadcastStream();
}
