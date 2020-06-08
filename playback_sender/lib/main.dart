import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(CarstenApplication());

class CarstenApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
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
