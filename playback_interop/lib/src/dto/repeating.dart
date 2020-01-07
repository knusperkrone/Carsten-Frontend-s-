part of 'dto.dart';

@JsonSerializable()
class RepeatingDto extends Dto {
  final bool isRepeating;

  RepeatingDto(this.isRepeating) : assert(isRepeating != null);

  factory RepeatingDto.fromJson(Map<String, dynamic> json) => _$RepeatingDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepeatingDtoToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) {
    if (other is RepeatingDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode {
    return isRepeating.hashCode;
  }
}
