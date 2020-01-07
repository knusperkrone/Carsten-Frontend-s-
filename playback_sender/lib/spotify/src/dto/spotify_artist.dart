part of 'dto.dart';

@JsonSerializable(createToJson: true)
class SpotifyArtist extends Dto {
  final String name;

  SpotifyArtist(this.name) : assert(name != null);

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) => _$SpotifyArtistFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyArtistToJson(this);
}
