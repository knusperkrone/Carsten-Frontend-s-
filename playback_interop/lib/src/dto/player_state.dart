part of 'dto.dart';

@JsonSerializable()
class PlayerStateDto extends Dto {

  final PlayerState state;

  PlayerStateDto(this.state) : assert(state != null);

  factory PlayerStateDto.fromJson(Map<String, dynamic> json) => _$PlayerStateDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlayerStateDtoToJson(this);


  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) {
    if (other is PlayerStateDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode => state.hashCode;

}