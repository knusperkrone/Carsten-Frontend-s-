part of 'dto.dart';

typedef GetterFun = int Function(SpotifyImage);

@JsonSerializable()
class SpotifyPlaylist extends Dto implements SpotifyFeatured {
  final String id;
  @override
  final String name;
  @JsonKey(name: 'snapshot_id')
  final String snapshotId;
  final List<SpotifyImage> images;
  final SpotifyUser owner;

  SpotifyPlaylist(this.id, this.name, this.snapshotId, this.images, this.owner)
      : assert(id != null &&
            name != null &&
            snapshotId != null &&
            images != null &&
            owner != null);

  factory SpotifyPlaylist.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPlaylistFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyPlaylistToJson(this);

  @override
  String get imageUrl {
    SpotifyImage selected;
    if (images != null && images.isNotEmpty) {
      selected = images.first;
    }
    return selected?.url ??
        'https://www.interface-ag.com/wp-content/uploads/elementor/thumbs/Logo_Mockup_InterFace_AG-oon15ikn17jbmwg17r1mswv2u8z4wu2pi3d8xdzz0o.png';
  }

  @override
  bool operator ==(dynamic other) {
    if (other is SpotifyPlaylist) {
      return other.id == id;
    }
    return false;
  }

  @override
  int get hashCode => id.hashCode;
}
