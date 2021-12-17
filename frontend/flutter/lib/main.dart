import 'dart:async';

import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'localization.dart';

Future<void> main() async {
  // Sentry logs
  const dsn = 'https://f5d43c1a57ba425b8404cb51181deb7c@sentry.if-lab.de/13';
  if (kReleaseMode) {
    await SentryFlutter.init(
      (options) => options.dsn = dsn,
      appRunner: () => runApp(CarstenApplication()),
    );
  } else {
    runApp(CarstenApplication());
  }
}

class CarstenApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('de', ''),
        Locale('de', 'AT'),
        Locale('de', 'CH'),
        Locale('de', 'DE'),
        Locale('de', 'LI'),
      ],
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        if (supportedLocales.contains(locale)) {
          return locale;
        }
        return const Locale('en', 'US');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: 'Carsten',
      theme: _prepareTheme(ThemeData.dark()),
      home: SplashScreen(),
    );
  }

  static ThemeData _prepareTheme(ThemeData theme) {
    const primaryColor = Color(0xffff80ab);
    const accentColor = Color(0xffff4081);
    const backgroundColor = Color(0xffff90b5);

    return theme.copyWith(
      androidOverscrollIndicator: AndroidOverscrollIndicator.stretch,
      primaryColor: primaryColor,
      colorScheme: theme.colorScheme.copyWith(secondary: accentColor),
      backgroundColor: backgroundColor,
      disabledColor: Colors.white60,
      sliderTheme: theme.sliderTheme.copyWith(
        inactiveTrackColor: backgroundColor,
        activeTrackColor: accentColor,
        thumbColor: accentColor,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
      ),
    );
  }
}
