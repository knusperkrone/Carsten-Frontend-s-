part of 'dto.dart';

@JsonSerializable(createToJson: true)
class SpotifyTrack extends Dto {
  final String href;
  final String name;
  final SpotifyAlbum album;
  final List<SpotifyArtist> artists;

  SpotifyTrack(this.href, this.name, this.album, this.artists);

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTrackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyTrackToJson(this);

  String get artist => artists.map((a) => a.name).join(', ');

  @override
  bool operator ==(dynamic other) {
    if (other is SpotifyTrack) {
      return other.href == href;
    }
    return false;
  }

  @override
  int get hashCode => href.hashCode;
}

@JsonSerializable(createToJson: true)
class SpotifyTracksLink extends Dto {
  final String href;
  final int total;

  SpotifyTracksLink(this.href, this.total);

  factory SpotifyTracksLink.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTracksLinkFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyTracksLinkToJson(this);

  @override
  bool operator ==(dynamic other) {
    if (other is SpotifyTracksLink) {
      return other.href == href;
    }
    return false;
  }

  @override
  int get hashCode => href.hashCode;
}
