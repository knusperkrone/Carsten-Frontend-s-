part of 'dto.dart';

@JsonSerializable(createToJson: true)
class SpotifyArtist extends Dto {
  final String name;

  SpotifyArtist(this.name) : assert(name != null);

  factory SpotifyArtist.fromJson(Map<String, dynamic> json) =>
      _$SpotifyArtistFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyArtistToJson(this);

  @override
  bool operator ==(dynamic other) {
    if (other is SpotifyArtist) {
      return other.name == name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}
