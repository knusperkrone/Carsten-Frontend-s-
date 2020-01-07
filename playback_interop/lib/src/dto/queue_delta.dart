part of 'dto.dart';

@JsonSerializable()
class AddPrioDeltaDto implements Dto {
  final PlaybackTrack track;
  final bool append;

  AddPrioDeltaDto(this.track, this.append) : assert(track != null && append != null);

  factory AddPrioDeltaDto.fromJson(Map<String, dynamic> json) => json == null ? null : _$AddPrioDeltaDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddPrioDeltaDtoToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) => (other is AddPrioDeltaDto) ? other.hashCode == hashCode : false;

  @override
  int get hashCode => track.hashCode;
}

@JsonSerializable()
class MovePrioDeltaDto implements Dto {
  final bool startPrio;
  final bool targetPrio;
  final int startIndex;
  final int targetIndex;

  MovePrioDeltaDto(this.startPrio, this.startIndex, this.targetPrio, this.targetIndex)
      : assert(startPrio != null && targetPrio != null && startIndex != null && targetIndex != null);

  factory MovePrioDeltaDto.fromJson(Map<String, dynamic> json) =>
      json == null ? null : _$MovePrioDeltaDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MovePrioDeltaDtoToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) => (other is MovePrioDeltaDto) ? other.hashCode == hashCode : false;

  @override
  int get hashCode => startPrio.hashCode + targetPrio.hashCode + startIndex + targetIndex;
}
