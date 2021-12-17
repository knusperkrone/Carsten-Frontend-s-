part of 'dto.dart';

// Serializable helpers
dynamic _genericObjectFromJson(dynamic json) => json;

dynamic _genericObjectToJson(dynamic item) => item;

@JsonSerializable()
class CastMessage<T> implements Dto {
  final String type;
  @JsonKey(fromJson: _genericObjectFromJson, toJson: _genericObjectToJson)
  final T data;

  CastMessage(this.type, this.data);

  factory CastMessage.fromJson(Map<String, dynamic> json) => _$CastMessageFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CastMessageToJson(this);

  /*
   * Equals boilerplate
   */

  @override
  bool operator ==(dynamic other) => (other is CastMessage) ? other.hashCode == hashCode : false;

  @override
  int get hashCode => type.hashCode + data.hashCode;
}
