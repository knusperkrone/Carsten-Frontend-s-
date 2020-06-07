import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/spotify/src/dto/spotify_featured.dart';
import 'package:chrome_tube/ui/page_track/track_page.dart';
import 'package:chrome_tube/ui/tracking/feature_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PlaylistHeader extends StatefulWidget {
  final List<SpotifyPlaylist> playlists;

  const PlaylistHeader({Key key, @required this.playlists}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new PlaylistHeaderState();
}

class PlaylistHeaderState extends State<PlaylistHeader> {
  List<SpotifyFeatured> _featured;

  @override
  void initState() {
    super.initState();
    _featured = new FeatureService().getLastFeatured();
  }

  Widget _buildHeaderText(String text) {
    return new Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(text, style: Theme.of(context).textTheme.headline6),
    );
  }

  Widget _buildPlaylistTile(int index) {
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
      content.add(_buildHeaderText('Zuletzt gehört'));
      for (int i = 0; i < _featured.length ~/ 2; i++) {
        content.add(Row(
          children: List.generate(2, (j) => _buildPlaylistTile(i * 2 + j)),
        ));
      }
    }
    content.add(_buildHeaderText('Deine Playlists'));

    return new Padding(
      padding: const EdgeInsets.only(left: 11.0, right: 11.0, top: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content,
      ),
    );
  }
}
