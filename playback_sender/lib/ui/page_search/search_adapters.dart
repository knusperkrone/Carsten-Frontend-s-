import 'package:chrome_tube/spotify/spotify.dart';
import 'package:chrome_tube/ui/page_search/search_page.dart';
import 'package:flutter/foundation.dart';

abstract class SearchAdapter {
  @protected
  final api = new SpotifyApi();

  Future<List<SerializableSearchResult>> search(String q);
}

class BestFitSearchAdapter extends SearchAdapter {
  @override
  Future<List<SerializableSearchResult>> search(String q) async {
    final results = <SerializableSearchResult>[];
    final triple = await api.searchAll(q);
    final playlists = triple.item1;
    final albums = triple.item2;
    final tracks = triple.item3;

    results.addAll(
        playlists.map((p) => SerializableSearchResult.fromPlaylist(p, q)));
    results.addAll(albums.map((a) => SerializableSearchResult.fromAlbum(a, q)));
    results.addAll(tracks.map((t) => SerializableSearchResult.fromTrack(t, q)));
    results.sort((e1, e2) => e1.bias - e2.bias);

    return results;
  }
}

class PlaylistsSearchAdapter extends SearchAdapter {
  @override
  Future<List<SerializableSearchResult>> search(String q) async {
    final results = <SerializableSearchResult>[];
    final playlists = await api.searchPlaylists(q);

    results.addAll(
        playlists.map((p) => SerializableSearchResult.fromPlaylist(p, q)));
    results.sort((e1, e2) => e1.bias - e2.bias);

    return results;
  }
}

class AlbumSearchAdapter extends SearchAdapter {
  @override
  Future<List<SerializableSearchResult>> search(String q) async {
    final results = <SerializableSearchResult>[];
    final albums = await api.searchAlbums(q);

    results.addAll(albums.map((a) => SerializableSearchResult.fromAlbum(a, q)));
    results.sort((e1, e2) => e1.bias - e2.bias);

    return results;
  }
}

class TrackSearchAdapter extends SearchAdapter {
  @override
  Future<List<SerializableSearchResult>> search(String q) async {
    final results = <SerializableSearchResult>[];
    final tracks = await api.searchTracks(q);

    results.addAll(tracks.map((t) => SerializableSearchResult.fromTrack(t, q)));
    results.sort((e1, e2) => e1.bias - e2.bias);

    return results;
  }
}
