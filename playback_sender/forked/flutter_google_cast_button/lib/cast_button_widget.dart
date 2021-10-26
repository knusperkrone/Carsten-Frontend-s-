import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_cast_button/bloc_media_route.dart';
import 'package:flutter_google_cast_button/flutter_google_cast_button.dart';

class CastButtonWidget extends StatefulWidget {
  final MediaRouteBloc? bloc;
  final Color? tintColor;
  final Color? backgroundColor;

  const CastButtonWidget({
    Key? key,
    this.bloc,
    this.tintColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CastButtonWidgetState();
}

class CastButtonWidgetState extends State<CastButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<String> connectingIconTween;
  late MediaRouteBloc _bloc;
  late Future animationFuture;
  MediaRouteState? currentState;

  static const packageName = 'flutter_google_cast_button';
  static const connectingAssets = [
    'assets/ic_cast0_black_24dp.png',
    'assets/ic_cast1_black_24dp.png',
    'assets/ic_cast2_black_24dp.png',
  ];

  void setBloc(MediaRouteBloc bloc) {
    setState(() => _bloc = bloc);
  }

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? BlocProvider.of<MediaRouteBloc>(context);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    connectingIconTween = TweenSequence<String>([
      TweenSequenceItem<String>(
        tween: ConstantTween<String>(connectingAssets[0]),
        weight: 34.0,
      ),
      TweenSequenceItem<String>(
        tween: ConstantTween<String>(connectingAssets[1]),
        weight: 33.0,
      ),
      TweenSequenceItem<String>(
        tween: ConstantTween<String>(connectingAssets[2]),
        weight: 33.0,
      ),
    ]).animate(_animationController);

    for (String path in connectingAssets) {
      Future(() async {
        final globalCache = PaintingBinding.instance!.imageCache!;
        final image = ExactAssetImage(path, package: packageName);
        final key = await image.obtainKey(
            createLocalImageConfiguration(context, size: const Size(24, 24)));
        final codec = PaintingBinding.instance!.instantiateImageCodec;
        globalCache.putIfAbsent(key, () => image.load(key, codec),
            onError: (dynamic _, s) => print('preload casting asset error'));
      });
    }
    connectingIconTween.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _bloc,
      builder: (context, MediaRouteState newState) {
        if (newState is NoDeviceAvailable) {
          currentState = newState;
          return IconButton(
              icon: Icon(Icons.cast, color: widget.tintColor),
              onPressed: () => FlutterGoogleCastButton.showCastDialog());
        }
        Widget icon;
        if (newState is Unconnected) {
          icon = Icon(Icons.cast, color: widget.tintColor);
        } else if (newState is Connected) {
          icon = Icon(Icons.cast_connected, color: widget.tintColor);
        } else {
          if (!_animationController.isAnimating) {
            Future.delayed(const Duration(milliseconds: 20), () {
              _animationController.forward(from: 0.0);
            });
          }
          icon = ImageIcon(
            ExactAssetImage(connectingIconTween.value, package: packageName),
            size: 24,
            color: widget.tintColor,
          );
        }
        currentState = newState;
        return IconButton(
          icon: icon,
          onPressed: () => FlutterGoogleCastButton.showCastDialog(),
        );
      },
    );
  }
}
