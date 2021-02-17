import 'dart:async';

import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry/sentry.dart';

import 'localization.dart';

void main() {
  // Sentry logs
  final sentry = SentryClient(
      dsn: 'https://f5d43c1a57ba425b8404cb51181deb7c@sentry.if-lab.de/13');

  FlutterError.onError = (details, {bool forceReport = false}) {
    if (kReleaseMode) {
      sentry.captureException(
        exception: details.exception,
        stackTrace: details.stack,
      );
    } else {
      print('SENDING ${details.exception}');
    }
  };

  runZonedGuarded(
    () => runApp(CarstenApplication()),
    (error, stackTrace) async {
      if (kReleaseMode) {
        await sentry.captureException(
          exception: error,
          stackTrace: stackTrace,
        );
      } else {
        print('SENDING $error');
      }
    },
  );
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
          (Locale locale, Iterable<Locale> supportedLocales) {
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
      primaryColor: primaryColor,
      accentColor: accentColor,
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
