part of 'dto.dart';

@JsonSerializable(createToJson: false)
class SpotifyPager extends Dto {
  final String next;
  final String previous;
  @JsonKey(fromJson: genericListFromJson, toJson: genericListToJson)
  final Iterable<dynamic> items;

  SpotifyPager(this.next, this.previous, this.items) : assert(items != null);

  factory SpotifyPager.fromJson(Map<String, dynamic> json) =>
      _$SpotifyPagerFromJson(json);

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError('Call this on this.items!');
  }

  @override
  bool operator ==(dynamic other) {
    if (other is SpotifyPager) {
      return other.next == next;
    }
    return false;
  }

  @override
  int get hashCode => next.hashCode;
}
