part of 'dto.dart';

@JsonSerializable()
class PlaybackTrack implements Dto {
  // Set by CAF
  final int origQueueIndex;
  final bool isPrio;
  int? durationMs;
  int? queueIndex;

  // CAF or locally constructed
  final String title;
  final String artist;
  final String album;
  final String? coverUrl;

  PlaybackTrack({
    required this.origQueueIndex,
    required this.isPrio,
    required this.title,
    required this.artist,
    required this.album,
    this.queueIndex,
    this.durationMs,
    this.coverUrl,
  });

  PlaybackTrack.dummy(
      {this.album = 'album',
      this.title = 'Mensch',
      this.artist = 'Herbert Grönemeyer',
      this.isPrio = false,
      this.coverUrl = '',
      this.durationMs = 12000,
      this.queueIndex = 0,
      this.origQueueIndex = 0});

  factory PlaybackTrack.fromJson(Map<String, dynamic> json) => _$PlaybackTrackFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaybackTrackToJson(this);

  factory PlaybackTrack.dtoHack(int index, String name) {
    return PlaybackTrack(
        origQueueIndex: index,
        queueIndex: index,
        title: name,
        coverUrl: '',
        isPrio: false,
        album: '',
        artist: '',
        durationMs: -1);
  }

  factory PlaybackTrack.copyWithPrio(bool isPrio, PlaybackTrack track) {
    return new PlaybackTrack(
      isPrio: isPrio,
      origQueueIndex: track.origQueueIndex,
      queueIndex: track.queueIndex,
      title: track.title,
      coverUrl: track.coverUrl,
      album: track.album,
      artist: track.artist,
      durationMs: track.durationMs,
    );
  }

  /*
   * to string
   */

  @override
  String toString() => '$title - $artist - $queueIndex, $origQueueIndex';

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) => (other is PlaybackTrack) ? other.hashCode == hashCode : false;

  @override
  int get hashCode =>
      origQueueIndex.hashCode +
      durationMs.hashCode +
      //queueIndex.hashCode +
      title.hashCode +
      artist.hashCode +
      album.hashCode +
      coverUrl.hashCode;
}
