import 'dart:convert';

import 'package:playback_interop/playback_interop.dart';
import 'package:playback_caf_dart/playback_caf.dart';
import 'package:playback_interop/src/dto/dto.dart';

import 'cast.dart' as js_cast;

class ChromecastCommunicationChannel extends CommunicationChannel {
  @override
  void sendMessage(CastMessage<Dto> castMsg) {
    final data = jsonEncode(castMsg.data.toJson());
    final msg = js_cast.CastMessage(type: castMsg.type, data: data);
    final context = js_cast.CastReceiverContext.getInstance();
    context.getSenders().forEach((sender) => context.sendCustomMessage(CHANNEL_NAMESPACE, sender.id, msg));
    // print('SEND: ${data}');
  }
}
