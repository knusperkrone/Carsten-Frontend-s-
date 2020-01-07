part of 'dto.dart';

@JsonSerializable()
class ErrorDto extends Dto {

  final PlayerError error;

  ErrorDto(this.error) : assert(error != null);

  factory ErrorDto.fromJson(Map<String, dynamic> json) => _$ErrorDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ErrorDtoToJson(this);


  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) {
    if (other is ErrorDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode {
    return error.hashCode;
  }

}