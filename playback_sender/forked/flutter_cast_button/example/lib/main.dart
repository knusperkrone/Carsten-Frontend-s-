import 'package:flutter/material.dart';
import 'package:flutter_cast_button/bloc_media_route.dart';
import 'package:flutter_cast_button/cast_button_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MediaRouteBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MediaRouteBloc();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: CastButtonWidget(bloc: _bloc),
        ),
      ),
    );
  }
}
