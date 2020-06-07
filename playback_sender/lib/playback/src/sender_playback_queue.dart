import 'package:flutter/foundation.dart';
import 'package:playback_interop/playback_interop.dart';

class SenderPlaybackQueue extends BasePlaybackQueue {
  final String name;

  factory SenderPlaybackQueue.empty() {
    return new SenderPlaybackQueue._internal(
        '', 0, null, null, false, false, [], []);
  }

  factory SenderPlaybackQueue.fromQueue(
      PlaybackQueueDto queueDto, bool isRepeating, bool isShuffling, int seed) {
    final name = queueDto.name;
    final currentTrack = queueDto.currentTrack;
    final trackHolder = queueDto.trackHolder;
    final prioTracks = queueDto.prioTracks;
    final trackList = queueDto.immutableTracks;

    return new SenderPlaybackQueue._internal(name, seed, currentTrack,
        trackHolder, isShuffling, isRepeating, prioTracks, trackList);
  }

  SenderPlaybackQueue._internal(
      this.name,
      int seed,
      PlaybackTrack currentTrack,
      PlaybackTrack trackHolder,
      bool isShuffling,
      bool isRepeating,
      List<PlaybackTrack> prioTracks,
      List<PlaybackTrack> mutableTrackList)
      : super(currentTrack, isShuffling, isRepeating, prioTracks,
            mutableTrackList,
            trackHolder: trackHolder, seed: seed);

  SenderPlaybackQueue._state({
    @required this.name,
    @required bool isDirty,
    @required bool isRepeating,
    @required ShuffleStateDto shuffleState,
    @required PlaybackTrack currTrackOpt,
    @required PlaybackTrack trackHolderOpt,
    @required String hash,
    @required List<PlaybackTrack> prioTracks,
    @required List<PlaybackTrack> mutableTrackList,
    @required List<PlaybackTrack> immutableTrackList,
  }) : super.withState(
          isDirty,
          isRepeating,
          shuffleState,
          currTrackOpt,
          trackHolderOpt,
          hash,
          prioTracks,
          mutableTrackList,
          immutableTrackList,
        );

  factory SenderPlaybackQueue.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    }

    final name = json['name'] as String;
    final hash = json['hash'] as String;
    final isDirty = json['isDirty'] as bool;
    final isRepeating = json['isRepeating'] as bool;
    final shuffleState = new ShuffleStateDto.fromJson(
        json['shuffleState'] as Map<String, dynamic>);
    final currentTrack = new PlaybackTrack.fromJson(
        json['currTrackOpt'] as Map<String, dynamic>);
    final trackHolder = new PlaybackTrack.fromJson(
        json['trackHolderOpt'] as Map<String, dynamic>);
    final prioTracks = (json['prioTracks'] as List<dynamic>)
        .map((dynamic json) =>
            new PlaybackTrack.fromJson(json as Map<String, dynamic>))
        .toList();
    final mutableTracks = (json['mutableTrackList'] as List<dynamic>)
        .map((dynamic json) =>
            new PlaybackTrack.fromJson(json as Map<String, dynamic>))
        .toList();
    final queueTracks = (json['immutableTrackList'] as List<dynamic>)
        .map((dynamic json) =>
            new PlaybackTrack.fromJson(json as Map<String, dynamic>))
        .toList();

    return new SenderPlaybackQueue._state(
      name: name,
      isDirty: isDirty,
      isRepeating: isRepeating,
      shuffleState: shuffleState,
      currTrackOpt: currentTrack,
      trackHolderOpt: trackHolder,
      hash: hash,
      prioTracks: prioTracks.cast<PlaybackTrack>(),
      mutableTrackList: mutableTracks.cast<PlaybackTrack>(),
      immutableTrackList: queueTracks.cast<PlaybackTrack>(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'isDirty': isDirty,
      'isRepeating': isRepeating,
      'hash': hash,
      'shuffleState': shuffleState.toJson(),
      'currTrackOpt': currentTrack?.toJson(),
      'trackHolderOpt': trackHolder?.toJson(),
      'prioTracks': prioTracks.map((t) => t.toJson()).toList(),
      'mutableTrackList': mutableTracks.map((t) => t.toJson()).toList(),
      'immutableTrackList': immutableTracks.map((t) => t.toJson()).toList(),
    };
  }
}
