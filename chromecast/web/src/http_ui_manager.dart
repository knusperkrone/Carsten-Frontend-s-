import 'dart:html';

import 'package:playback_caf_dart/src/playback/ui_manager.dart';

class HttpUiManager extends UiManager {
  HttpUiManager() {
    new Future.delayed(const Duration(seconds: 0), () => showReady());
  }

  @override
  void showPlayer(bool isShowing) {
    querySelector('#youTubePlayerDOM')!.style.visibility = isShowing ? 'visible' : 'hidden';
  }

  @override
  void showReady() {
    querySelector('#spinner')?.remove();
    querySelector('#text')!.innerHtml = 'Ready for Carsten';
  }
}
