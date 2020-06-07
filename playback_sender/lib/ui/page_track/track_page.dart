import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/spotify/src/dto/spotify_featured.dart';
import 'package:chrome_tube/ui/common/control/control_bar.dart';
import 'package:chrome_tube/ui/common/transformer.dart';
import 'package:chrome_tube/ui/tracking/feature_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:optional/optional.dart';
import 'package:palette_generator/palette_generator.dart';

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
      print('Invalid feature: $feature');
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

    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
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

    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
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
    return Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return new TrackPage._(trackStream, palette, 'Songs', null,
          appBarImageProvider, appBarHeight, const Optional.empty(),
          key: key);
    }));
  }

  @override
  State createState() => new TrackPageState();
}

class TrackPageState extends State<TrackPage> {
  static const TEXT_SIZE = 40.0;
  List<SpotifyTrack> _tracks = [];
  StreamSubscription _streamSub;
  bool _hasFetched = false;

  Color _gradientColor;

  @override
  void initState() {
    super.initState();
    // Stream sub
    if (widget.trackStream == null) {
      _hasFetched = true;
    } else {
      _streamSub = widget.trackStream.listen((fetched) async {
        _tracks.addAll(fetched);
        if (mounted) {
          setState(() => _tracks = _tracks);
        }
        _streamSub.pause();
        await Future<void>.delayed(const Duration(milliseconds: 400));
        _streamSub.resume();
      });
      _streamSub.onDone(() => setState(() => _hasFetched = true));
    }

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
    if (_hasFetched) {
      PlaybackManager().sendShuffling(true);
      _onTrack(Random().nextInt(_tracks.length).abs());
    }
  }

  void _onTrack(int selected) {
    final sendList = new List.generate(_tracks.length, (i) {
      return PlaybackTransformer.fromSpotify(_tracks[i], i);
    });
    widget.featured.ifPresent((curr) => FeatureService().addFeature(curr));
    PlaybackManager().sendTracks(sendList, selected, widget.collectionName);
  }

  void _onTrackSecondary(SpotifyTrack track) {
    final playbackTrack =
        PlaybackTransformer.fromSpotify(track, -1, isPrio: true);
    PlaybackManager().sendAddToPrio(playbackTrack);
  }

  /*
   * Build
   */

  Widget _buildTrackTile(int i, BuildContext context) {
    final curr = _tracks[i];
    final key = new GlobalKey<SlidableState>();
    return Slidable(
      key: key,
      actionPane: const SlidableDrawerActionPane(),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Queue Track',
          color: Theme.of(context).accentColor,
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
                      delegate: _TrackPageAppBar(
                        imageProvider: widget.appBarImageProvider,
                        gradientColor: _gradientColor,
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
                      delegate: SliverChildListDelegate(
                        List.generate(
                            _tracks.length, (i) => _buildTrackTile(i, context)),
                      ),
                    ),
                    SliverToBoxAdapter(child: scrollPadding),
                  ],
                ),
              ),
              ControlBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackPageAppBar extends SliverPersistentHeaderDelegate {
  static const SHUFFLE_SIZE = 35.0;

  final double expandedHeight;
  final String name;
  final String owner;
  final ImageProvider imageProvider;
  final Color gradientColor;
  final double textSize;
  final VoidCallback onShuffle;

  _TrackPageAppBar({
    @required this.expandedHeight,
    @required this.textSize,
    @required this.name,
    @required this.owner,
    @required this.imageProvider,
    @required this.gradientColor,
    @required this.onShuffle,
  });

  /*
   * Build
   */

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final qWidth = MediaQuery.of(context).size.width;

    final Color gradientVal = gradientColor ?? Theme.of(context).primaryColor;
    final double colorRelation = min(0.2, shrinkOffset / expandedHeight);
    final Color gradientStart = new Color.fromARGB(
      255,
      max(0, gradientVal.red - (gradientVal.red * colorRelation).toInt()),
      max(0, gradientVal.green - (gradientVal.green * colorRelation).toInt()),
      max(0, gradientVal.blue - (gradientVal.blue * colorRelation).toInt()),
    );

    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.8, 0.8],
              colors: [
                gradientStart,
                Theme.of(context).canvasColor,
                Colors.transparent
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: kToolbarHeight / 2 + shrinkOffset / 4),
          child: Opacity(
            opacity: max(0, 1 - (shrinkOffset / expandedHeight) * 2),
            child: Column(
              children: <Widget>[
                Image(
                    image: imageProvider,
                    width: qWidth - qWidth / 4 - shrinkOffset,
                    height: expandedHeight -
                        kToolbarHeight -
                        shrinkOffset -
                        40.0 -
                        SHUFFLE_SIZE,
                    fit: BoxFit.fitHeight),
                Container(
                  padding: const EdgeInsets.only(top: 12.0),
                  height:
                      textSize - (shrinkOffset / expandedHeight) * textSize + 6,
                  child: owner == null
                      ? Container()
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10.0)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            owner,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: Colors.white),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: kToolbarHeight / 4,
          child: Container(
            width: qWidth,
            child: Opacity(
              opacity: shrinkOffset / expandedHeight,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          top: max(minExtent - 10.0 - SHUFFLE_SIZE,
              expandedHeight - 10.0 - SHUFFLE_SIZE - shrinkOffset),
          left: qWidth / 6,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 5,
            color: Theme.of(context).accentColor,
            child: SizedBox(
              height: 47.0,
              width: qWidth / 1.5,
              child: FloatingActionButton.extended(
                backgroundColor: Theme.of(context).accentColor,
                heroTag: 'second',
                elevation: 0.0,
                label: const Text('Shuffle'),
                foregroundColor: Colors.white,
                onPressed: onShuffle,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white70,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + SHUFFLE_SIZE;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
