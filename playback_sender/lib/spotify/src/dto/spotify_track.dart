part of 'dto.dart';

@JsonSerializable(createToJson: true)
class SpotifyTrack extends Dto {
  final String href;
  final String name;
  final SpotifyAlbum album;
  final List<SpotifyArtist> artists;

  SpotifyTrack(this.href, this.name, this.album, this.artists)
      : assert(name != null && album != null && artists != null);

  factory SpotifyTrack.fromJson(Map<String, dynamic> json) =>
      _$SpotifyTrackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyTrackToJson(this);

  String get artist => artists.map((a) => a.name).join(', ');
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
}
