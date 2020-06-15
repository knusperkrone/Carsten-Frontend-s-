import 'package:chrome_tube/localization.dart';
import 'package:flutter/material.dart';

abstract class CachingState<T extends StatefulWidget> extends State<T> {
  AppLocalizations _localizationCache;
  ThemeData _themeCache;

  @protected
  AppLocalizations get locale {
    _localizationCache ??= AppLocalizations.of(context);
    return _localizationCache;
  }

  @protected
  ThemeData get theme {
    _themeCache ??= Theme.of(context);
    return _themeCache;
  }
}
