import 'package:optional/optional.dart';
import 'package:playback_interop/playback_interop.dart';

class CafPlaybackQueue extends BasePlaybackQueue {
  final String name;

  factory CafPlaybackQueue.withQueue(Optional<BasePlaybackQueue> queue, List<PlaybackTrack> dtoList) {
    // Extract from old list
    final prioTracks = queue.isPresent ? queue.value.prioTracks : <PlaybackTrack>[];
    final isRepeating = queue.isPresent ? queue.value.isRepeating : false;
    final isShuffling = queue.isPresent ? queue.value.isShuffled : false;

    // Dto hack
    assert(dtoList.length > 1);
    final dtoHack = dtoList.removeAt(0);
    final name = dtoHack.title;
    final currentTrack = dtoList[dtoHack.queueIndex];
    return new CafPlaybackQueue._internal(name, currentTrack, isShuffling, isRepeating, prioTracks, dtoList);
  }

  CafPlaybackQueue.empty()
      : name = '',
        super.withState(false, false, new ShuffleStateDto(null, false, 0), null, null,
            'invalid', [], [], []);

  CafPlaybackQueue._internal(this.name, PlaybackTrack currentTrack, bool isShuffling, bool isRepeating,
      List<PlaybackTrack> prioList, List<PlaybackTrack> mutableTrackList)
      : assert(name != null),
        super(currentTrack, isShuffling, isRepeating, prioList, mutableTrackList);

  PlaybackQueueDto get dto {
    return new PlaybackQueueDto(
      currentTrack: currentTrack,
      trackHolder: trackHolder,
      prioTracks: prioTracks,
      immutableTracks: immutableTracks,
      name: name,
      hash: hash, // optional
    );
  }
}
