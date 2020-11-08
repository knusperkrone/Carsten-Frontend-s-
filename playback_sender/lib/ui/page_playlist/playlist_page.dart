import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/playback/src/playback_listeners.dart';
import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/ui/common/common.dart';
import 'package:chrome_tube/ui/common/state.dart';
import 'package:chrome_tube/ui/page_playlist/playlist_header.dart';
import 'package:chrome_tube/ui/pages.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistPage extends StatefulWidget {
  final List<SpotifyPlaylist> playlists;

  const PlaylistPage(this.playlists, {Key key}) : super(key: key);

  @override
  State createState() => _PlaylistPageState();
}

class _PlaylistPageState extends RootState<PlaylistPage> {
  bool _isFetching = false;
  final _headerKey = new GlobalKey<PlaylistHeaderState>();
  final _controlKey = new GlobalKey<ControlBarState>();

  /*
   * UI-Callbacks
   */

  @override
  void onEvent(PlaybackUIEvent event) {
    // No-Op
  }

  Future<void> _onSearch() async {
    final prefs = await SharedPreferences.getInstance();
    Navigator.push<void>(context, new FadeInRoute(builder: (context) {
      return new SearchPage(prefs);
    }));
  }

  Future<void> _navigateToSongPage(BuildContext context) async {
    if (!_isFetching) {
      _isFetching = true;
      await TrackPage.navigateTracks(context);
      _isFetching = false;
      _controlKey.currentState?.refreshMediaState();
      _headerKey.currentState?.refresh();
    }
  }

  Future<void> _navigateToTrackPage(
      BuildContext context, SpotifyPlaylist playlist) async {
    if (!_isFetching) {
      _isFetching = true;
      await TrackPage.navigatePlaylist(context, playlist);
      _isFetching = false;
      _controlKey.currentState?.refreshMediaState();
      _headerKey.currentState?.refresh();
    }
  }

  /*
   * Build
   */

  Widget _buildTiles(BuildContext context, int i) {
    if (i == 0) {
      return PlaylistHeader(key: _headerKey);
    } else if (i == 1) {
      return _buildTrackTile(context);
    }
    return _buildPlaylistTile(context, i - 2);
  }

  Widget _buildTrackTile(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: ListTile(
        contentPadding: const EdgeInsets.only(top: 5.0),
        leading: Container(
          width: 60,
          height: 60,
          child: const Icon(Icons.album),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.bottomRight,
              colors: [theme.accentColor, theme.canvasColor],
            ),
          ),
        ),
        title: Text(
          locale.translate('songs'),
          style:
              theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
        onTap: () => _navigateToSongPage(context),
      ),
    );
  }

  Widget _buildPlaylistTile(BuildContext context, int i) {
    final playlist = widget.playlists[i];
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: ListTile(
        contentPadding: const EdgeInsets.only(top: 5.0),
        leading: Image(
          image: CachedNetworkImageProvider(
            playlist.imageUrl,
          ),
          fit: BoxFit.cover,
          height: 60,
          width: 60,
        ),
        title: Text(
          playlist.name,
          style:
              theme.textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(playlist.owner.name),
        onTap: () => _navigateToTrackPage(context, playlist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView.builder(
          itemCount: widget.playlists.length + 2,
          itemBuilder: _buildTiles,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ControlBar(key: _controlKey),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.accentColor,
        heroTag: 'second',
        child: const Icon(Icons.search),
        onPressed: _onSearch,
      ),
    );
  }
}
