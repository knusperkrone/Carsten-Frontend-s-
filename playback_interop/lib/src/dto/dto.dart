import 'package:meta/meta.dart';

import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cast_message.dart';
part 'dto.g.dart';
part 'error.dart';
part 'playback_queue.dart';
part 'playback_track.dart';
part 'player_state.dart';
part 'queue_delta.dart';
part 'ready.dart';
part 'repeating.dart';
part 'seek.dart';
part 'shuffle_state.dart';
part 'state.dart';
part 'track_state.dart';

abstract class Dto {
  Map<String, dynamic> toJson();

  @override
  bool operator ==(dynamic other) {
    if (runtimeType == other.runtimeType) {
      return hashCode == other.hashCode;
    }
    return false;
  }

  @override
  int get hashCode {
    throw UnimplementedError('Needs to be overritten by subclass!');
  }
}
