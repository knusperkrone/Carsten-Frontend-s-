part of 'dto.dart';

@JsonSerializable()
class AddPrioDeltaDto implements Dto {
  final PlaybackTrack track;
  final bool append;

  AddPrioDeltaDto(this.track, this.append);

  factory AddPrioDeltaDto.fromJson(Map<String, dynamic> json) => _$AddPrioDeltaDtoFromJson(json);

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

  MovePrioDeltaDto(this.startPrio, this.startIndex, this.targetPrio, this.targetIndex);

  factory MovePrioDeltaDto.fromJson(Map<String, dynamic> json) => _$MovePrioDeltaDtoFromJson(json);

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
