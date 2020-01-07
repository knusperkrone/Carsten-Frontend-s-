part of 'dto.dart';

@JsonSerializable()
class ShuffleStateDto implements Dto {
  final PlaybackTrack startTrack;
  final bool isShuffled;
  final int initSeed;

  ShuffleStateDto(this.startTrack, this.isShuffled, this.initSeed) : assert(isShuffled != null) {
    if (isShuffled) {
      assert(startTrack != null && initSeed != null);
    }
  }

  factory ShuffleStateDto.fromJson(Map<String, dynamic> json) => json == null ? null : _$ShuffleStateDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ShuffleStateDtoToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) => (other is ShuffleStateDto) ? other.hashCode == hashCode : false;

  @override
  int get hashCode => startTrack.hashCode + isShuffled.hashCode + initSeed;
}
