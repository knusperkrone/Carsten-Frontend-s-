import 'dart:async';

import 'package:chrome_tube/localization.dart';
import 'package:chrome_tube/playback/playback.dart';
import 'package:flutter/material.dart';

abstract class CachingState<T extends StatefulWidget> extends State<T> {
  AppLocalizations? _localizationCache;
  ThemeData? _themeCache;

  @protected
  AppLocalizations get locale {
    _localizationCache ??= AppLocalizations.of(context);
    return _localizationCache!;
  }

  @protected
  ThemeData get theme {
    _themeCache ??= Theme.of(context);
    return _themeCache!;
  }
}

abstract class UIListener {
  void onEvent(PlaybackUIEvent event);
}

abstract class UIListenerState<T extends StatefulWidget> extends CachingState<T>
    implements UIListener {
  @protected
  late StreamSubscription uiSub;

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

abstract class RootState<T extends StatefulWidget> extends UIListenerState<T> {
  final _dialogKey = new GlobalKey<_VolumeDialogState>();
  final PlaybackManager _manager = new PlaybackManager();
  late StreamSubscription _volumeButtonSubscription;

  @override
  void initState() {
    super.initState();
    _volumeButtonSubscription =
        _manager.volumeEvents.listen((VolumeEvent event) async {
      if (_dialogKey.currentState?.mounted ?? false) {
        _dialogKey.currentState?.volumeEvent(event);
      } else {
        await showDialog<void>(
          context: context,
          builder: (context) => _VolumeDialog(
            key: _dialogKey,
            manager: _manager,
            event: event,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _volumeButtonSubscription.cancel();
    super.dispose();
  }
}

class _VolumeDialog extends StatefulWidget {
  final VolumeEvent event;
  final PlaybackManager manager;

  const _VolumeDialog({Key? key, required this.event, required this.manager})
      : super(key: key);

  @override
  State createState() => new _VolumeDialogState();
}

class _VolumeDialogState extends CachingState<_VolumeDialog> {
  double _volume = 0.0;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    volumeEvent(widget.event);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void volumeEvent(VolumeEvent event) {
    _delayDismiss();
    Future<double> fut;
    if (event == VolumeEvent.UP) {
      fut = widget.manager.volumeUp();
    } else {
      fut = widget.manager.volumeDown();
    }
    fut.then((value) => setState(() => _volume = value));
  }

  void _delayDismiss() {
    _dismissTimer?.cancel();
    _dismissTimer =
        Timer(const Duration(milliseconds: 1500), () => Navigator.pop(context));
  }

  void _onSlide(double value) {
    _delayDismiss();
    widget.manager
        .setVolume(value)
        .then((value) => setState(() => _volume = value));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: <Widget>[
        const Icon(
          Icons.airplay,
          size: 70,
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              locale.translate('volume'),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        Slider(
          value: _volume,
          onChanged: _onSlide,
        ),
      ],
    );
  }
}
