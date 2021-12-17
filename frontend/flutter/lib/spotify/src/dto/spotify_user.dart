part of 'dto.dart';

@JsonSerializable()
class SpotifyUser extends Dto {
  @JsonKey(name: 'display_name')
  final String name;

  SpotifyUser(this.name);

  factory SpotifyUser.fromJson(Map<String, dynamic> json) =>
      _$SpotifyUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpotifyUserToJson(this);

  @override
  bool operator ==(dynamic other) {
    if (other is SpotifyUser) {
      return other.name == name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;
}
