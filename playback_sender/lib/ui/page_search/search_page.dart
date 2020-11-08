import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:async/async.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/ui/common/connect_dialog.dart';
import 'package:chrome_tube/ui/common/control/control_bar.dart';
import 'package:chrome_tube/ui/common/state.dart';
import 'package:chrome_tube/ui/common/transformer.dart';
import 'package:chrome_tube/ui/page_track/track_page.dart';
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_page.g.dart';

part 'search_result.dart';

class SearchPage extends StatefulWidget {
  final SharedPreferences prefs;

  const SearchPage(this.prefs);

  @override
  State createState() => SearchPageState();
}

class SearchPageState extends CachingState<SearchPage> {
  static const _MAX_SEARCH_SIZE = 10;
  static const _SEARCH_PREFS_KEY = 'SEARCH_PREF_KEY';

  final PlaybackManager _manager = new PlaybackManager();
  final SpotifyApi _spotify = new SpotifyApi();
  final List<SerializableSearchResult> _results = [];
  LinkedHashSet<SerializableSearchResult> _prevSearches;
  TextEditingController _textController;
  CancelableOperation _currSearch;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Get the sorted searches
    final savedSearches = widget.prefs.getStringList(_SEARCH_PREFS_KEY) ?? [];
    final searchList = savedSearches
        .map((str) => SerializableSearchResult.fromJson(str))
        .toList();
    _prevSearches = LinkedHashSet.of(searchList);

    _textController = new TextEditingController();
    _textController.addListener(_onText);
  }

  @override
  void dispose() {
    _currSearch?.cancel();
    _textController.removeListener(_onText);
    _textController.dispose();
    super.dispose();
  }

  /*
   * Helpers
   */

  void _onText() {
    _currSearch?.cancel();
    if (_textController.text.isEmpty) {
      setState(() => _results.clear());
    } else {
      final q = _textController.text.toLowerCase();
      final searchFuture = _spotify.search(q);
      _currSearch =
          CancelableOperation.fromFuture(searchFuture).then<void>((triple) {
        if (!mounted) {
          return;
        }
        setState(() {
          final playlists =
              triple.item1.sublist(0, min(triple.item1.length, 5));
          final albums = triple.item2.sublist(0, min(triple.item2.length, 5));
          final tracks = triple.item3;

          _results.clear();
          _results.addAll(playlists
              .map((p) => SerializableSearchResult.fromPlaylist(p, q)));
          _results.addAll(
              albums.map((a) => SerializableSearchResult.fromAlbum(a, q)));
          _results.addAll(
              tracks.map((t) => SerializableSearchResult.fromTrack(t, q)));
          _results.sort((e1, e2) => e1.bias - e2.bias);
        });
      });
    }
  }

  void _addToSearchResults(SerializableSearchResult result) {
    final mutated = _prevSearches.add(result);
    if (_prevSearches.length > _MAX_SEARCH_SIZE) {
      _prevSearches.remove(_prevSearches.first);
    }

    if (mutated) {
      final searchJson = _prevSearches.map((t) => t.toJson()).toList();
      widget.prefs.setStringList(_SEARCH_PREFS_KEY, searchJson);
    }
  }

  /*
   * UI callbacks
   */

  Future<void> onPlaylist(SpotifyPlaylist playlist) async {
    if (!_isNavigating) {
      _isNavigating = true;
      final result = new SerializableSearchResult.fromPlaylist(playlist);
      _addToSearchResults(result);

      await TrackPage.navigatePlaylist(context, playlist);
      _isNavigating = false;
    }
  }

  Future<void> onTrack(SpotifyTrack track) async {
    final result = new SerializableSearchResult.fromTrack(track);
    _addToSearchResults(result);

    final playbackTrack =
        PlaybackTransformer.fromSpotify(track, -1, isPrio: true);

    try {
      await _manager.sendPlayTrack(playbackTrack);
    } catch (_) {
      showDialog<void>(
        context: context,
        builder: (_) => ConnectChromeCastDialog(),
      );
    }
  }

  Future<void> onAlbum(SpotifyAlbum album) async {
    if (!_isNavigating) {
      _isNavigating = true;
      final result = new SerializableSearchResult.fromAlbum(album);
      _addToSearchResults(result);

      await TrackPage.navigateAlbum(context, album);
      _isNavigating = false;
    }
  }

  void _onTrackSecondary(String trackJson) {
    final track = new SpotifyTrack.fromJson(
        jsonDecode(trackJson) as Map<String, dynamic>);
    final result = new SerializableSearchResult.fromTrack(track);
    _addToSearchResults(result);

    final playbackTrack =
        PlaybackTransformer.fromSpotify(track, -1, isPrio: true);
    _manager.sendAddToPrio(playbackTrack);
  }

  void onClose(SerializableSearchResult result) {
    setState(() {
      _prevSearches.remove(result);
      final searchJson = _prevSearches.map((t) => t.toJson()).toList();
      widget.prefs.setStringList(_SEARCH_PREFS_KEY, searchJson);
    });
  }

  /*
   * Build
   */

  Widget _buildSearchedTitle(BuildContext context, int i) {
    final result = _prevSearches.skip(i).first;
    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      actions: result.type != SearchType.TRACK
          ? []
          : <Widget>[
              IconSlideAction(
                caption: locale.translate('queue_button'),
                color: theme.accentColor,
                icon: Icons.queue_music,
                onTap: () => _onTrackSecondary(result.serialized),
              ),
            ],
      child: SearchResult(
        parent: this,
        searchResult: result,
        trailing: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => onClose(result),
        ),
      ),
    );
  }

  Widget _buildResultTile(BuildContext context, int i) {
    final curr = _results[i];
    final key = GlobalKey<SlidableState>();
    Widget tile = SearchResult(
      searchResult: curr,
      parent: this,
      trailing: curr.type == SearchType.TRACK
          ? IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () =>
                  key.currentState.open(actionType: SlideActionType.primary),
            )
          : null,
    );

    if (curr.type == SearchType.TRACK) {
      tile = Slidable(
        key: key,
        actionPane: const SlidableDrawerActionPane(),
        actions: <Widget>[
          IconSlideAction(
            caption: locale.translate('queue_button'),
            color: theme.accentColor,
            icon: Icons.queue_music,
            onTap: () => _onTrackSecondary(curr.serialized),
          ),
        ],
        child: tile,
      );
    }
    return tile;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          controller: _textController,
          decoration: InputDecoration(
            hintText: locale.translate('search'),
          ),
        ),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: ControlBar(),
      ),
      body: CustomScrollView(
        slivers: _textController.text.isEmpty
            ? <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    _buildSearchedTitle,
                    childCount: _prevSearches.length,
                  ),
                ),
              ]
            : <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    _buildResultTile,
                    childCount: _results.length,
                  ),
                ),
              ],
      ),
    );
  }
}
