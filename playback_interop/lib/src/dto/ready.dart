part of 'dto.dart';

@JsonSerializable()
class ReadyDto extends Dto {
  final bool ready;

  ReadyDto(this.ready) : assert(ready != null);

  factory ReadyDto.fromJson(Map<String, dynamic> json) => _$ReadyDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ReadyDtoToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) {
    if (other is ReadyDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode {
    return ready.hashCode;
  }
}
