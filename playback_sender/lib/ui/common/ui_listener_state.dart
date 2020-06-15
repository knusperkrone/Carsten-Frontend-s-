import 'dart:async';

import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/ui/common/localiation_state.dart';
import 'package:flutter/material.dart';

abstract class UIListener {
  void onEvent(PlaybackUIEvent event);
}

abstract class UIListenerState<T extends StatefulWidget> extends CachingState<T>
    implements UIListener {
  @protected
  StreamSubscription uiSub;

  @override
  void initState() {
    super.initState();
    uiSub = new PlaybackManager().stream.listen(onEvent);
  }

  @override
  void dispose() {
    uiSub.pause();
    uiSub.cancel();
    super.dispose();
  }
}
