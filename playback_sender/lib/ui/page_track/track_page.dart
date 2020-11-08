import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/localization.dart';
import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/spotify/src/dto/spotify_featured.dart';
import 'package:chrome_tube/ui/common/connect_dialog.dart';
import 'package:chrome_tube/ui/common/control/control_bar.dart';
import 'package:chrome_tube/ui/common/state.dart';
import 'package:chrome_tube/ui/common/transformer.dart';
import 'package:chrome_tube/ui/common/transitions.dart';
import 'package:chrome_tube/ui/tracking/feature_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:optional/optional.dart';
import 'package:palette_generator/palette_generator.dart';

import 'track_app_bar.dart';

class TrackPage extends StatefulWidget {
  final Stream<List<SpotifyTrack>> trackStream;
  final String collectionName;
  final String collectionOwner;
  final PaletteGenerator palette;
  final ImageProvider appBarImageProvider;
  final double expandedHeight;
  final Optional<SpotifyFeatured> featured;

  const TrackPage._(
      this.trackStream,
      this.palette,
      this.collectionName,
      this.collectionOwner,
      this.appBarImageProvider,
      this.expandedHeight,
      this.featured,
      {Key key})
      : super(key: key);

  static void navigateFeatured(BuildContext context, SpotifyFeatured feature) {
    if (feature is SpotifyPlaylist) {
      navigatePlaylist(context, feature);
    } else if (feature is SpotifyAlbum) {
      navigateAlbum(context, feature);
    } else {
      throw StateError('Invalid type: $feature');
    }
  }

  static Future<void> navigatePlaylist(
      BuildContext context, SpotifyPlaylist playlist,
      {Key key}) async {
    final appBarHeight = MediaQuery.of(context).size.height / 10 * 5;
    final appBarImageProvider =
        new CachedNetworkImageProvider(playlist.imageUrl);
    final stream = SpotifyApi().getPlaylistTracks(playlist);
    final palette =
        await PaletteGenerator.fromImageProvider(appBarImageProvider);

    return Navigator.push<void>(context, new FadeInRoute(builder: (context) {
      return new TrackPage._(
          stream,
          palette,
          playlist.name,
          playlist.owner.name,
          appBarImageProvider,
          appBarHeight,
          Optional.of(playlist),
          key: key);
    }));
  }

  static Future<void> navigateAlbum(BuildContext context, SpotifyAlbum album,
      {Key key}) async {
    final appBarHeight = MediaQuery.of(context).size.height / 10 * 5;
    final appBarImageProvider = new CachedNetworkImageProvider(album.imageUrl);
    final stream = SpotifyApi().getAlbumTracks(album);
    final palette =
        await PaletteGenerator.fromImageProvider(appBarImageProvider);

    return Navigator.push<void>(context, new FadeInRoute(builder: (context) {
      return new TrackPage._(stream, palette, album.name, album.artist,
          appBarImageProvider, appBarHeight, Optional.of(album),
          key: key);
    }));
  }

  static Future<void> navigateTracks(BuildContext context, {Key key}) async {
    final appBarHeight = MediaQuery.of(context).size.height / 10 * 2.5;
    const appBarImageProvider =
        ExactAssetImage('assets/images/transparent.png');

    final trackStream = SpotifyApi().getUserTracks();
    final palette = PaletteGenerator.fromColors(
        [PaletteColor(Theme.of(context).primaryColor, 1)]);
    return Navigator.push<void>(context, new FadeInRoute(builder: (context) {
      final songs = AppLocalizations.of(context).translate('songs');
      return new TrackPage._(trackStream, palette, songs, null,
          appBarImageProvider, appBarHeight, const Optional.empty(),
          key: key);
    }));
  }

  @override
  State createState() => new TrackPageState();
}

class TrackPageState extends CachingState<TrackPage> {
  static const TEXT_SIZE = 40.0;
  List<SpotifyTrack> _tracks = [];
  StreamSubscription _streamSub;
  String _text = '';

  Color _gradientColor;

  @override
  void initState() {
    super.initState();
    // Stream sub
    _streamSub = widget.trackStream?.listen((fetched) async {
      if (fetched == null) {
        _tracks.clear();
      } else {
        _tracks.addAll(fetched);
      }
      if (mounted) {
        _text = locale.translate('shuffle');
        setState(() {
          _tracks = _tracks;
          _text = _text;
        });
      }
    });

    // Get color
    _gradientColor = widget.palette.vibrantColor?.color;
    if (_gradientColor == null) {
      _gradientColor = widget.palette.dominantColor.color;
    } else {
      final dominantColor = widget.palette.dominantColor.color;
      int colorDelta = 0;
      colorDelta += (_gradientColor.red - dominantColor.red).abs();
      colorDelta += (_gradientColor.green - dominantColor.green).abs();
      colorDelta += (_gradientColor.blue - dominantColor.blue).abs();
      if (colorDelta > 255 && colorDelta < 300) {
        _gradientColor = widget.palette.dominantColor.color;
      }
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  /*
   * UI callbacks
   */

  void _onShuffle() {
    PlaybackManager().sendShuffling(true);
    _onTrack(Random().nextInt(_tracks.length).abs());
  }

  Future<void> _onTrack(int selected) async {
    final sendList = new List.generate(_tracks.length, (i) {
      return PlaybackTransformer.fromSpotify(_tracks[i], i);
    });
    widget.featured.ifPresent((curr) => FeatureService().addFeature(curr));

    try {
      await PlaybackManager()
          .sendTracks(sendList, selected, widget.collectionName);
    } catch (e) {
      showDialog<void>(
        context: context,
        builder: (_) => ConnectChromeCastDialog(),
      );
    }
  }

  void _onTrackSecondary(SpotifyTrack track) {
    final playbackTrack =
        PlaybackTransformer.fromSpotify(track, -1, isPrio: true);
    PlaybackManager().sendAddToPrio(playbackTrack);
  }

  /*
   * Build
   */

  Widget _buildTrackTile(BuildContext context, int i) {
    final curr = _tracks[i];
    final key = new GlobalKey<SlidableState>();
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Slidable(
        key: key,
        actionPane: const SlidableDrawerActionPane(),
        actions: <Widget>[
          IconSlideAction(
            caption: locale.translate('queue_button'),
            color: theme.accentColor,
            icon: Icons.queue_music,
            onTap: () => _onTrackSecondary(curr),
          ),
        ],
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          title: Text(curr.name ?? ''),
          subtitle: Text(curr.artist ?? ''),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () =>
                key.currentState?.open(actionType: SlideActionType.primary),
          ),
          onTap: () => _onTrack(i),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollPadding = Container(
      height: max(
          0,
          MediaQuery.of(context).size.height -
              kToolbarHeight -
              35.0 -
              80 * (_tracks.length + 1)),
    );
    final statusBarColor = new Color.fromARGB(
      255,
      max(0, _gradientColor.red - (_gradientColor.red * 0.3).toInt()),
      max(0, _gradientColor.green - (_gradientColor.green * 0.3).toInt()),
      max(0, _gradientColor.blue - (_gradientColor.blue * 0.3).toInt()),
    );

    return Container(
      color: statusBarColor,
      child: SafeArea(
        child: Material(
          child: Column(
            children: <Widget>[
              Expanded(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: TrackPageAppBar(
                        imageProvider: widget.appBarImageProvider,
                        gradientColor: _gradientColor,
                        text: _text,
                        name: widget.collectionName,
                        owner: widget.collectionOwner,
                        expandedHeight: widget.expandedHeight,
                        textSize: TEXT_SIZE,
                        onShuffle: _onShuffle,
                      ),
                    ),
                    SliverToBoxAdapter(child: Container(height: 8.0)),
                    SliverFixedExtentList(
                      itemExtent: 80.0,
                      delegate: SliverChildBuilderDelegate(
                        _buildTrackTile,
                        childCount: _tracks.length,
                      ),
                    ),
                    SliverToBoxAdapter(child: scrollPadding),
                  ],
                ),
              ),
              const ControlBar(),
            ],
          ),
        ),
      ),
    );
  }
}
