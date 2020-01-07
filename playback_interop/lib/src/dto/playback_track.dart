part of 'dto.dart';

@JsonSerializable()
class PlaybackTrack implements Dto {
  // Set by CAF
  final int origQueueIndex;
  final bool isPrio;
  @JsonKey(nullable: true)
  int durationMs;
  @JsonKey(nullable: true)
  int queueIndex;

  // CAF or locally constructed
  final String title;
  final String artist;
  final String album;
  @JsonKey(nullable: true)
  final String coverUrl;

  PlaybackTrack({
    @required this.origQueueIndex,
    @required this.durationMs,
    @required this.isPrio,
    @required this.queueIndex,
    @required this.title,
    @required this.artist,
    @required this.album,
    @required this.coverUrl,
  }) : assert(origQueueIndex != null &&
            isPrio != null &&
            queueIndex != null &&
            title != null &&
            artist != null &&
            album != null);

  PlaybackTrack.dummy(
      {this.album = 'album',
      this.title = 'Mensch',
      this.artist = 'Herbert Grönemeyer',
      this.isPrio = false,
      this.coverUrl = '',
      this.durationMs = 12000,
      this.queueIndex = 0,
      this.origQueueIndex = 0});

  factory PlaybackTrack.fromJson(Map<String, dynamic> json) => json == null ? null : _$PlaybackTrackFromJson(json);

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
