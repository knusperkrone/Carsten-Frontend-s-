import 'package:chrome_tube/utils/serializable_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dto.g.dart';
part 'spotify_album.dart';
part 'spotify_artist.dart';
part 'spotify_image.dart';
part 'spotify_pager.dart';
part 'spotify_playlist.dart';
part 'spotify_track.dart';
part 'spotify_user.dart';

abstract class Dto {
  Map<String, dynamic> toJson();
}
