part of 'dto.dart';

@JsonSerializable(createToJson: true)
class SpotifyAlbum extends Dto {
  final String id;
  final String name;
  final List<SpotifyImage> images;
  final List<SpotifyArtist> artists;

  SpotifyAlbum(this.id, this.name, this.images, this.artists)
      : assert(id != null && name != null && images != null && artists != null);

  String get artist => artists.map((a) => a.name).join(', ');

  factory SpotifyAlbum.fromJson(Map<String, dynamic> json) => _$SpotifyAlbumFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyAlbumToJson(this);

  String get imageUrl {
    final offset = images.length > 1 ? 2 : 1;
    return images[images.length - offset].url;
  }
}
