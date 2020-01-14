import 'package:js/js.dart' show allowInterop;
import 'package:playback_caf_dart/playback_caf.dart';
import 'package:playback_interop/playback_interop.dart';

import 'src/cast.dart' as js_cast;

import 'src/cast_communication_channel.dart';
import 'src/cast_message_dispatcher.dart';
import 'src/http_ui_manager.dart';
import 'src/youtube_player.dart';

void main() {
  final uiManager = new HttpUiManager();
  final channel = ChromecastCommunicationChannel();
  final manager = new PlaybackManager(channel, uiManager);
  final dispatcher = new CastMessageDispatcher(manager);

  final context = js_cast.CastReceiverContext.getInstance();
  context.addEventListener('ready', allowInterop((_) {
    new YoutubePlayer(manager); // Poltergeist
  }));
  context.addCustomMessageListener(CHANNEL_NAMESPACE, allowInterop(dispatcher.onMessage));
  context.start(js_cast.CastRecevierOptions(disableIdleTimeout: true));
}
