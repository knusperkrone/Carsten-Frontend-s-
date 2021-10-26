part of 'search_page.dart';

enum SearchType { TRACK, PLAYLIST, ALBUM }

@JsonSerializable()
class SerializableSearchResult {
  // ignore: non_constant_identifier_names
  static final NormalizedStringDistance _CMP = new CombinedJaccard();

  final String url;
  final String name;
  final String parent;
  final String serialized;
  final SearchType type;
  @JsonKey(ignore: true)
  int bias;

  SerializableSearchResult(
      this.url, this.name, this.parent, this.serialized, this.type);

  SerializableSearchResult.fromTrack(SpotifyTrack track, [String q])
      : url = track.album.images.last.url,
        name = track.name,
        parent = track.artist,
        serialized = jsonEncode(track.toJson()),
        type = SearchType.TRACK {
    _setBias(q);
  }

  SerializableSearchResult.fromPlaylist(SpotifyPlaylist playlist, [String q])
      : url = playlist.images?.last?.url,
        name = playlist.name,
        parent = playlist.owner?.name ?? '',
        serialized = jsonEncode(playlist.toJson()),
        type = SearchType.PLAYLIST {
    _setBias(q);
  }

  SerializableSearchResult.fromAlbum(SpotifyAlbum album, [String q])
      : url = album.images.last.url,
        name = album.name,
        parent = album.artist,
        serialized = jsonEncode(album.toJson()),
        type = SearchType.ALBUM {
    _setBias(q);
  }

  void _setBias(String q) {
    if (q == null) {
      bias = 0;
    } else {
      // This works surprisingly well.
      final distances = <int>[];
      for (final q in q.split(' ')) {
        double distance = _CMP.normalizedDistance(q, name);
        if (type == SearchType.TRACK) {
          distance -= 0.025;
        } else if (type == SearchType.PLAYLIST) {
          distance += 0.0;
        }
        distances.add((distance * 1000).toInt());
      }
      bias = distances.reduce((e1, e2) => min(e1, e2));
    }
  }

  /*
   * Equality boilerplate
   */

  @override
  bool operator ==(dynamic other) =>
      (runtimeType != other.runtimeType) ? false : hashCode == other.hashCode;

  @override
  int get hashCode => hashValues(url, name, parent, type); // no index!

  /*
   * Serializable boilerplate
   */

  factory SerializableSearchResult.fromJson(String jsonStr) =>
      _$SerializableSearchResultFromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>);

  String toJson() => jsonEncode(_$SerializableSearchResultToJson(this));
}

class SearchResult extends StatelessWidget {
  final SerializableSearchResult searchResult;
  final SearchPageState parent;
  final Widget trailing;

  const SearchResult(
      {Key key,
      @required this.searchResult,
      @required this.parent,
      @required this.trailing})
      : super(key: key);

  void _onTab() {
    final json = jsonDecode(searchResult.serialized) as Map<String, dynamic>;
    switch (searchResult.type) {
      case SearchType.TRACK:
        parent.onTrack(new SpotifyTrack.fromJson(json));
        break;
      case SearchType.PLAYLIST:
        parent.onPlaylist(new SpotifyPlaylist.fromJson(json));
        break;
      case SearchType.ALBUM:
        parent.onAlbum(new SpotifyAlbum.fromJson(json));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String typeStr =
        searchResult.type.toString().substring('SearchType'.length + 1);
    typeStr = '${typeStr[0]}${typeStr.substring(1).toLowerCase()}';
    return new ListTile(
      leading: CachedNetworkImage(
        imageUrl: searchResult.url,
        height: 50.0,
        width: 50.0,
        fit: BoxFit.fill,
      ),
      title: Text(searchResult.name),
      subtitle: Text('$typeStr • ${searchResult.parent}'),
      dense: true,
      onTap: _onTab,
      trailing: trailing,
    );
  }
}
