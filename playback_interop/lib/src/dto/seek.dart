part of 'dto.dart';

@JsonSerializable()
class SeekDto extends Dto {
  final int seekMs;

  SeekDto(this.seekMs) : assert(seekMs != null);

  factory SeekDto.fromJson(Map<String, dynamic> json) => _$SeekDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SeekDtoToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) {
    if (other is SeekDto) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode {
    return seekMs.hashCode;
  }
}
