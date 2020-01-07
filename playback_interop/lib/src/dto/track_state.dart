part of 'dto.dart';

@JsonSerializable()
class TrackStateDto implements Dto {
  final TrackState trackState;
  final int trackIndex;
  final int durationMs;

  TrackStateDto({@required this.trackState, @required this.trackIndex, this.durationMs})
      : assert(trackState != null && trackIndex != null);

  factory TrackStateDto.fromJson(Map<String, dynamic> json) => _$TrackStateDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TrackStateDtoToJson(this);

  @override
  bool operator ==(dynamic other) {
    if (other is TrackStateDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode => trackIndex.hashCode + durationMs.hashCode + trackState.hashCode;
}
