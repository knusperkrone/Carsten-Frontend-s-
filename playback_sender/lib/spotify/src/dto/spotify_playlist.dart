part of 'dto.dart';

typedef GetterFun = int Function(SpotifyImage);

@JsonSerializable()
class SpotifyPlaylist extends Dto {
  final String id;
  final String name;
  @JsonKey(name: 'snapshot_id')
  final String snapshotId;
  final List<SpotifyImage> images;
  final SpotifyUser owner;

  SpotifyPlaylist(this.id, this.name, this.snapshotId, this.images, this.owner)
      : assert(id != null && name != null && snapshotId != null && images != null && owner != null);

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) => _$SpotifyPlaylistFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyPlaylistToJson(this);

  String get imageUrl {
    if (images == null) {
      return '';
    }

    final offset = images.length > 1 ? 2 : 1;
    return images[images.length - offset].url;
  }
}
