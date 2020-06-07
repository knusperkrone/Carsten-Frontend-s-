part of 'dto.dart';

@JsonSerializable(createToJson: true)
class SpotifyImage extends Dto {
  final int height;
  final int width;
  final String url;

  SpotifyImage(this.height, this.width, this.url) : assert(url != null);

  factory SpotifyImage.fromJson(Map<String, dynamic> json) =>
      _$SpotifyImageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyImageToJson(this);
}
