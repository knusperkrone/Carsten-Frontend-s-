import 'package:chrome_tube/spotify/spotify.dart';
import 'package:playback_interop/playback_interop.dart';

mixin PlaybackTransformer {
  static const _DEFAULT_IMG =
      'https://assets.kununu.com/assets/images_company/201704/crop_380_380/interface-ag_de4ce9868a840e63110dfb20f85e8d7c.jpg';

  static PlaybackTrack fromSpotify(SpotifyTrack track, int index,
      {bool isPrio = false}) {
    final album = track.album;
    String imgUrl = _DEFAULT_IMG;
    if (album?.images?.isNotEmpty ?? false) {
      final offset = album.images.length > 1 ? 0 : 1;
      imgUrl = album.images[offset].url;
    }
    return new PlaybackTrack(
      title: track.name,
      artist: track.artist,
      album: track.album?.name ?? '',
      origQueueIndex: index,
      queueIndex: index,
      coverUrl: imgUrl,
      durationMs: null,
      isPrio: isPrio,
    );
  }
}
