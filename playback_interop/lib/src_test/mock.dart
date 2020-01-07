import 'dart:convert';

import 'package:playback_interop/src/dto/dto.dart';

// ReadyDTO
const expReady = false;
const _readyDtoMap = {'ready': expReady};
final readyDtoJson = jsonEncode(_readyDtoMap);

// RepatingDTO
const expRepeatingDto = false;
const _repeatingDtoMap = {'isRepeating': expRepeatingDto};
final repeatingDtoJson = jsonEncode(_repeatingDtoMap);

//SeekDTO
const expSeekDtoSeekMs = 0x80;
const _seekDtoMap = {'seekMs': expSeekDtoSeekMs};
final seekDtoJson = jsonEncode(_seekDtoMap);

// PlayerStateDTO
const expPlayerStateDtoState = PlayerState.PLAYING;
final _playerStateDtoMap = {
  'state': expPlayerStateDtoState.toJson(),
};
final playerStateDtoJson = jsonEncode(_playerStateDtoMap);

// ErrorState
const expErrorState = PlayerError.VIDEO_NOT_FOUND;
final _errorStateDtoMap = {
  'error': expErrorState.toJson(),
};
final errorStateDtoJson = jsonEncode(_errorStateDtoMap);

// TrackStateDTO
const expTrackDtoState = TrackState.NEXT;
const expTrackDtoIndex = 2;
final _trackStateDtoMap = {
  'trackState': expTrackDtoState.toJson(),
  'trackIndex': expTrackDtoIndex,
};
final trackStateDtoJson = jsonEncode(_trackStateDtoMap);

// PlaybackTrack Json
const expTrackOrigQueueIndex = 24;
const expTrackDurationMs = 999;
const expTrackQueueIndex = 9;
const expTrackTitle = 'Der Taum ist aus';
const expTrackArtist = 'Ton Steine Scherben';
const expTrackAlbum = 'Keine Macht für Niemand';
const expTrackCoverUrl = 'www.cover.com/url';
const _trackMap = {
  'origQueueIndex': expTrackOrigQueueIndex,
  'durationMs': expTrackDurationMs,
  'queueIndex': expTrackQueueIndex,
  'title': expTrackTitle,
  'artist': expTrackArtist,
  'album': expTrackAlbum,
  'coverUrl': expTrackCoverUrl,
  'isPrio': false
};
final trackJson = jsonEncode(_trackMap);

final _trackStateMap = {
  'track': _trackMap,
  'seekMs': 10,
};
final trackStateJson = jsonEncode(_trackStateMap);

const expQueueName = 'name';
const expQueueHash = '86850deb2742ec3cb41518e26aa2d89';
const expQueueListLength = 2;
const _queueMap = {
  'currentTrack': _trackMap,
  'trackHolder': _trackMap,
  'prioTracks': <PlaybackTrack>[],
  'immutableTracks': [_trackMap, _trackMap],
  'name': expQueueName,
  'hash': expQueueHash,
};
final queueJson = jsonEncode(_queueMap);

const expShuffleStateShuffled = true;
const expShuffleStateSeed = 42;
const _shuffledMap = {
  'startTrack': _trackMap,
  'trackHolder': _trackMap,
  'isShuffled': expShuffleStateShuffled,
  'initSeed': expShuffleStateSeed,
};
final shuffledJson = jsonEncode(_shuffledMap);

const expAddPrioAppend = true;
const _addPrioMap = {
  'track': _trackMap,
  'append': expAddPrioAppend,
};
final addPrioJson = jsonEncode(_addPrioMap);

const expMovStartPrio = true;
const expMovStartIndex = 0;
const expMovTargetPrio = false;
const expMovTargetIndex = 42;
const _movMap = {
  'startPrio': expMovStartPrio,
  'startIndex': expMovStartIndex,
  'targetPrio': expMovTargetPrio,
  'targetIndex': expMovTargetIndex,
  'normIndex': 0,
};
final movDeltaJson = jsonEncode(_movMap);
