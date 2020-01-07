// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CastMessage<T> _$CastMessageFromJson<T>(Map<String, dynamic> json) {
  return CastMessage<T>(
    json['type'] as String,
    _genericObjectFromJson(json['data']) as T,
  );
}

Map<String, dynamic> _$CastMessageToJson<T>(CastMessage<T> instance) =>
    <String, dynamic>{
      'type': instance.type,
      'data': _genericObjectToJson(instance.data),
    };

ErrorDto _$ErrorDtoFromJson(Map<String, dynamic> json) {
  return ErrorDto(
    json['error'] == null
        ? null
        : PlayerError.fromJson(json['error'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$ErrorDtoToJson(ErrorDto instance) => <String, dynamic>{
      'error': instance.error,
    };

PlaybackQueueDto _$PlaybackQueueDtoFromJson(Map<String, dynamic> json) {
  return PlaybackQueueDto(
    currentTrack: json['currentTrack'] == null
        ? null
        : PlaybackTrack.fromJson(json['currentTrack'] as Map<String, dynamic>),
    trackHolder: json['trackHolder'] == null
        ? null
        : PlaybackTrack.fromJson(json['trackHolder'] as Map<String, dynamic>),
    prioTracks: (json['prioTracks'] as List)
        ?.map((dynamic e) => e == null
            ? null
            : PlaybackTrack.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    immutableTracks: (json['immutableTracks'] as List)
        ?.map((dynamic e) => e == null
            ? null
            : PlaybackTrack.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    name: json['name'] as String,
    hash: json['hash'] as String,
  );
}

Map<String, dynamic> _$PlaybackQueueDtoToJson(PlaybackQueueDto instance) =>
    <String, dynamic>{
      'currentTrack': instance.currentTrack,
      'trackHolder': instance.trackHolder,
      'prioTracks': instance.prioTracks,
      'immutableTracks': instance.immutableTracks,
      'name': instance.name,
      'hash': instance.hash,
    };

PlaybackTrack _$PlaybackTrackFromJson(Map<String, dynamic> json) {
  return PlaybackTrack(
    origQueueIndex: json['origQueueIndex'] as int,
    durationMs: json['durationMs'] as int,
    isPrio: json['isPrio'] as bool,
    queueIndex: json['queueIndex'] as int,
    title: json['title'] as String,
    artist: json['artist'] as String,
    album: json['album'] as String,
    coverUrl: json['coverUrl'] as String,
  );
}

Map<String, dynamic> _$PlaybackTrackToJson(PlaybackTrack instance) =>
    <String, dynamic>{
      'origQueueIndex': instance.origQueueIndex,
      'isPrio': instance.isPrio,
      'durationMs': instance.durationMs,
      'queueIndex': instance.queueIndex,
      'title': instance.title,
      'artist': instance.artist,
      'album': instance.album,
      'coverUrl': instance.coverUrl,
    };

PlayerStateDto _$PlayerStateDtoFromJson(Map<String, dynamic> json) {
  return PlayerStateDto(
    json['state'] == null
        ? null
        : PlayerState.fromJson(json['state'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PlayerStateDtoToJson(PlayerStateDto instance) =>
    <String, dynamic>{
      'state': instance.state,
    };

AddPrioDeltaDto _$AddPrioDeltaDtoFromJson(Map<String, dynamic> json) {
  return AddPrioDeltaDto(
    json['track'] == null
        ? null
        : PlaybackTrack.fromJson(json['track'] as Map<String, dynamic>),
    json['append'] as bool,
  );
}

Map<String, dynamic> _$AddPrioDeltaDtoToJson(AddPrioDeltaDto instance) =>
    <String, dynamic>{
      'track': instance.track,
      'append': instance.append,
    };

MovePrioDeltaDto _$MovePrioDeltaDtoFromJson(Map<String, dynamic> json) {
  return MovePrioDeltaDto(
    json['startPrio'] as bool,
    json['startIndex'] as int,
    json['targetPrio'] as bool,
    json['targetIndex'] as int,
  );
}

Map<String, dynamic> _$MovePrioDeltaDtoToJson(MovePrioDeltaDto instance) =>
    <String, dynamic>{
      'startPrio': instance.startPrio,
      'targetPrio': instance.targetPrio,
      'startIndex': instance.startIndex,
      'targetIndex': instance.targetIndex,
    };

ReadyDto _$ReadyDtoFromJson(Map<String, dynamic> json) {
  return ReadyDto(
    json['ready'] as bool,
  );
}

Map<String, dynamic> _$ReadyDtoToJson(ReadyDto instance) => <String, dynamic>{
      'ready': instance.ready,
    };

RepeatingDto _$RepeatingDtoFromJson(Map<String, dynamic> json) {
  return RepeatingDto(
    json['isRepeating'] as bool,
  );
}

Map<String, dynamic> _$RepeatingDtoToJson(RepeatingDto instance) =>
    <String, dynamic>{
      'isRepeating': instance.isRepeating,
    };

SeekDto _$SeekDtoFromJson(Map<String, dynamic> json) {
  return SeekDto(
    json['seekMs'] as int,
  );
}

Map<String, dynamic> _$SeekDtoToJson(SeekDto instance) => <String, dynamic>{
      'seekMs': instance.seekMs,
    };

ShuffleStateDto _$ShuffleStateDtoFromJson(Map<String, dynamic> json) {
  return ShuffleStateDto(
    json['startTrack'] == null
        ? null
        : PlaybackTrack.fromJson(json['startTrack'] as Map<String, dynamic>),
    json['isShuffled'] as bool,
    json['initSeed'] as int,
  );
}

Map<String, dynamic> _$ShuffleStateDtoToJson(ShuffleStateDto instance) =>
    <String, dynamic>{
      'startTrack': instance.startTrack,
      'isShuffled': instance.isShuffled,
      'initSeed': instance.initSeed,
    };

TrackStateDto _$TrackStateDtoFromJson(Map<String, dynamic> json) {
  return TrackStateDto(
    trackState: json['trackState'] == null
        ? null
        : TrackState.fromJson(json['trackState'] as Map<String, dynamic>),
    trackIndex: json['trackIndex'] as int,
    durationMs: json['durationMs'] as int,
  );
}

Map<String, dynamic> _$TrackStateDtoToJson(TrackStateDto instance) =>
    <String, dynamic>{
      'trackState': instance.trackState,
      'trackIndex': instance.trackIndex,
      'durationMs': instance.durationMs,
    };
