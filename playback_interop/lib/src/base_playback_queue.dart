import 'package:collection/collection.dart';

import 'dto/dto.dart';
import 'playback_shuffler.dart';

abstract class BasePlaybackQueue {
  final _shuffler = new PlaybackShuffler();
  bool _isDirty = false;
  bool _isRepeating;

  ShuffleStateDto _shuffleState;
  PlaybackTrack _currTrackOpt;
  PlaybackTrack _trackHolderOpt;

  final String _hash;
  final List<PlaybackTrack> _prioTracks;
  final List<PlaybackTrack> _mutableTrackList;
  final List<PlaybackTrack> _immutableTrackList;

  BasePlaybackQueue(
      PlaybackTrack currentTrack, bool isShuffling, this._isRepeating, this._prioTracks, this._mutableTrackList,
      {PlaybackTrack trackHolder, int seed = 0})
      : _immutableTrackList = new List.unmodifiable(_mutableTrackList),
        _hash = const ListEquality<dynamic>().hash(_mutableTrackList).toString(),
        assert(isShuffling != null && _isRepeating != null && _prioTracks != null && _mutableTrackList != null) {
    _currTrackOpt = currentTrack;
    if (trackHolder != null) {
      _trackHolderOpt = trackHolder;
    } else {
      _trackHolderOpt = currentTrack;
    }

    setShuffling(isShuffling, seed);
  }

  BasePlaybackQueue.withState(
    this._isDirty,
    this._isRepeating,
    this._shuffleState,
    this._currTrackOpt,
    this._trackHolderOpt,
    this._hash,
    this._prioTracks,
    this._mutableTrackList,
    this._immutableTrackList,
  );

  /*
   * Cross platform code
   */

  PlaybackTrack nextTrack() {
    PlaybackTrack nextTrack;
    if (_prioTracks.isNotEmpty) {
      nextTrack = _prioTracks.removeAt(0);
      _currTrackOpt = nextTrack;
      for (int i = 0; i < _prioTracks.length; i++) {
        _prioTracks[i].queueIndex = i;
      }
      nextTrack.queueIndex = 0; // index fix
      assert(nextTrack.isPrio == true);
      return nextTrack;
    } else if (_trackHolderOpt == null) {
      // Necessary due inconsistency in prio queue
      _currTrackOpt = null;
      return null;
    }

    assert(_trackHolderOpt != null);
    if (_currTrackOpt.isPrio && _trackHolderOpt.queueIndex + 1 < _mutableTrackList.length) {
      nextTrack = _mutableTrackList[_trackHolderOpt.queueIndex + 1];
    } else if (_currTrackOpt.queueIndex + 1 >= _mutableTrackList.length) {
      if (_isRepeating) {
        nextTrack = _mutableTrackList.first;
      } else {
        nextTrack = null;
      }
    } else {
      nextTrack = _mutableTrackList[_currTrackOpt.queueIndex + 1];
    }

    assert(!(nextTrack?.isPrio ?? false));
    _currTrackOpt = nextTrack;
    _trackHolderOpt = nextTrack;
    return nextTrack;
  }

  PlaybackTrack peekNext() {
    PlaybackTrack peekTrack;
    if (_prioTracks.isNotEmpty) {
      peekTrack = _prioTracks.first;
      return peekTrack;
    } else if (_trackHolderOpt == null) {
      return null;
    }

    assert(_trackHolderOpt != null);
    if (_currTrackOpt.isPrio && _trackHolderOpt.queueIndex + 1 < _mutableTrackList.length) {
      peekTrack = _mutableTrackList[_trackHolderOpt.queueIndex + 1];
    } else if (_currTrackOpt.queueIndex + 1 >= _mutableTrackList.length) {
      if (_isRepeating) {
        peekTrack = _mutableTrackList.first;
      } else {
        peekTrack = null; // implicit
      }
    } else {
      peekTrack = _mutableTrackList[_currTrackOpt.queueIndex + 1];
    }

    return peekTrack;
  }

  PlaybackTrack previousTrack() {
    PlaybackTrack prevTrack;
    if (_currTrackOpt == null || _trackHolderOpt == null) {
      return null;
    }

    if (_currTrackOpt.isPrio) {
      prevTrack = _trackHolderOpt;
    } else if (_currTrackOpt.queueIndex == 0) {
      prevTrack = _currTrackOpt;
    } else {
      prevTrack = _mutableTrackList[_currTrackOpt.queueIndex - 1];
    }

    assert(!(prevTrack?.isPrio ?? false));
    _currTrackOpt = prevTrack;
    _trackHolderOpt = prevTrack;
    return prevTrack;
  }

  void addPrioTrack(PlaybackTrack prioTrack, bool append) {
    assert(prioTrack.isPrio == true);
    if (append) {
      prioTrack.queueIndex = _prioTracks.length;
      _prioTracks.add(prioTrack);
    } else {
      // prepend
      _prioTracks.insert(0, prioTrack);
      for (int i = 0; i < _prioTracks.length; i++) {
        _prioTracks[i].queueIndex = i;
      }
    }
  }

  void setShuffling(bool isShuffled, int seed) {
    if (_currTrackOpt == null) {
      throw new StateError('Nothing to shuffle!');
    }
    final shuffleState = new ShuffleStateDto(_currTrackOpt, isShuffled, seed);
    setShuffleState(shuffleState);
  }

  void setRepeating(bool isRepeating) {
    _isRepeating = isRepeating;
  }

  void setShuffleState(ShuffleStateDto shuffleState) {
    _shuffleState = shuffleState;

    // All tracks from original Playlist
    final List<PlaybackTrack> allTracks = List.of(_immutableTrackList);
    List<PlaybackTrack> changedActiveTracks;

    if (shuffleState.isShuffled) {
      final List<PlaybackTrack> toShuffle = allTracks;

      // Shuffle whole playlist, without current (non-prio) song
      PlaybackTrack startTrack;
      if (!shuffleState.startTrack.isPrio) {
        // Remove the real list element, so references are still valid
        final removeIndex = toShuffle.indexOf(shuffleState.startTrack);
        if (removeIndex == -1) {
          throw new StateError('Coulnd\nt find track ${shuffleState.startTrack}');
        }
        startTrack = toShuffle.removeAt(removeIndex);
      }

      changedActiveTracks = _shuffler.shuffle(shuffleState.initSeed, toShuffle);

      // (Re-)Enumerate tracks
      if (startTrack != null) {
        changedActiveTracks.insert(0, startTrack);
      }
      for (int i = 0; i < changedActiveTracks.length; i++) {
        changedActiveTracks[i].queueIndex = i;
      }
    } else {
      // Play the rest of all songs, after the current song
      changedActiveTracks = allTracks;

      // (Re-)Enumerate tracks
      for (final track in changedActiveTracks) {
        track.queueIndex = track.origQueueIndex;
      }
    }

    _mutableTrackList.clear();
    _mutableTrackList.addAll(changedActiveTracks);
  }

  void move(bool startPrio, int startIndex, bool targetPrio, int targetIndex) {
    if (_currTrackOpt == null || _trackHolderOpt == null) {
      throw new StateError('[ERROR] move:\nNo current track!');
    }

    final startList = startPrio ? _prioTracks : _mutableTrackList;
    final targetList = targetPrio ? _prioTracks : _mutableTrackList;

    if (startIndex < 0 || startIndex > startList.length || targetIndex < 0 || targetIndex > targetList.length) {
      throw new ArgumentError('[ERROR] move:\nInvalid index!');
    }

    // Swap
    PlaybackTrack moveTrack = startList.removeAt(startIndex);
    moveTrack = new PlaybackTrack.copyWithPrio(targetPrio, moveTrack);
    if (targetList.length == targetIndex) {
      targetList.add(moveTrack);
    } else {
      targetList.insert(targetIndex, moveTrack);
    }

    final makesDirty = !startPrio || !targetPrio;
    if (makesDirty) {
      _isDirty = true;

      // Reiterate current list
      final normIndex = _trackHolderOpt.queueIndex;
      for (int i = 0; i < _mutableTrackList.length; i++) {
        _mutableTrackList[i].queueIndex = normIndex + i;
      }
    }

    if (startPrio || targetPrio) {
      if (_currTrackOpt != null && _currTrackOpt.isPrio) {
        _currTrackOpt.queueIndex = 0;
      }
      // Reinumerate prioList
      for (int i = 0; i < _prioTracks.length; i++) {
        _prioTracks[i].queueIndex = i;
      }
    }
  }

/*
   * Getters
   */

  PlaybackTrack get currentTrack => _currTrackOpt;

  PlaybackTrack get trackHolder => _trackHolderOpt;

  String get hash => _isDirty ? null : _hash;

  int get seed => _shuffleState.initSeed;

  bool get isDirty => _isDirty;

  bool get isRepeating => _isRepeating;

  bool get isShuffled => _shuffleState.isShuffled;

  ShuffleStateDto get shuffleState => _shuffleState;

  List<PlaybackTrack> get prioTracks => _prioTracks;

  List<PlaybackTrack> get mutableTracks => _mutableTrackList;

  List<PlaybackTrack> get immutableTracks => _immutableTrackList;
}
