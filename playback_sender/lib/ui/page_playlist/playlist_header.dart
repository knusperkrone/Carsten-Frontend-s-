import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/spotify/src/dto/spotify_featured.dart';
import 'package:chrome_tube/ui/common/state.dart';
import 'package:chrome_tube/ui/page_track/track_page.dart';
import 'package:chrome_tube/ui/tracking/feature_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PlaylistHeader extends StatefulWidget {
  const PlaylistHeader({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new PlaylistHeaderState();
}

class PlaylistHeaderState extends CachingState<PlaylistHeader> {
  List<SpotifyFeatured> _featured;

  @override
  void initState() {
    super.initState();
    _featured = new FeatureService().getLastFeatured();
  }

  void refresh() {
    setState(() {
      _featured = new FeatureService().getLastFeatured();
    });
  }

  Widget _buildHeaderText(String text) {
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(text, style: theme.textTheme.headline6),
    );
  }

  Widget _buildPlaylistTile(int index) {
    if (index >= _featured.length) {
      return Container();
    }
    final feature = _featured[index];
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 11.0,
      child: InkWell(
        onTap: () => TrackPage.navigateFeatured(context, feature),
        child: Card(
          child: Row(
            children: <Widget>[
              Image(
                image: CachedNetworkImageProvider(feature.imageUrl),
                fit: BoxFit.cover,
                height: 45,
                width: 45,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    feature.name,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[];
    if (_featured.isNotEmpty) {
      content.add(_buildHeaderText(locale.translate('playlist_last')));
      for (int i = 0; i < (_featured.length / 2).round(); i++) {
        content.add(Row(
          children: List.generate(2, (j) => _buildPlaylistTile(i * 2 + j)),
        ));
      }
    }
    content.add(_buildHeaderText(locale.translate('playlist_all')));

    return new Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 7.0, top: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }
}
