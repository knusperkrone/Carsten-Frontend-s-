part of 'dto.dart';

@JsonSerializable()
class PlaybackQueueDto implements Dto {
  @JsonKey(ignore: true)
  static const _LIST_EQUALITY = ListEquality<PlaybackTrack>();

  final PlaybackTrack? currentTrack;
  final PlaybackTrack? trackHolder;
  final List<PlaybackTrack>? prioTracks;
  final List<PlaybackTrack> immutableTracks;
  final String? name;
  final String? hash;

  PlaybackQueueDto({
    required this.currentTrack,
    required this.trackHolder,
    required this.prioTracks,
    required this.immutableTracks,
    required this.name,
    required this.hash,
  });

  @override
  factory PlaybackQueueDto.fromJson(Map<String, dynamic> json) => _$PlaybackQueueDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaybackQueueDtoToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) => (other is PlaybackQueueDto) ? other.hashCode == hashCode : false;

  @override
  int get hashCode => currentTrack.hashCode + hash.hashCode + _LIST_EQUALITY.hash(immutableTracks);
}
