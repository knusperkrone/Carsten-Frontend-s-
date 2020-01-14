import 'package:mockito/mockito.dart';
import 'package:playback_caf_dart/playback_caf.dart';
import 'package:playback_caf_dart/src/playback/ui_manager.dart';
import 'package:playback_interop/playback_interop.dart';
import 'package:playback_interop/src_test/constant.dart';

import 'package:playback_interop/src_test/generator.dart';
import 'package:test/test.dart';

class MockedUI extends Mock implements UiManager {}

class MockedBridge extends Mock implements CommunicationChannel {}

class MockedPlayer extends Mock implements PlaybackPlayer {}

void main() {
  List<PlaybackTrack> tracks;
  PlaybackManager manager;
  MockedBridge channel;

  setUp(() {
    final player = new MockedPlayer();
    channel = new MockedBridge();
    manager = new PlaybackManager(channel, MockedUI());
    manager.onPlayerReady(player);

    // Pre-execute
    tracks = generateTracks();
    manager.appendToQueue([new PlaybackTrack.dtoHack(0, '')]);
    manager.appendToQueue(tracks);
    manager.appendToQueue([]);
  });

  test('on Ready', () {
    verify(channel.sendReady(true)).called(1); // onPlayerReady!
  });

  test('On tracks', () {
    // validate
    final sendDto = verify(channel.sendQueue(captureAny)).captured.first.value as CafPlaybackQueue;
    verify(channel.sendShuffleState(any)).called(1);
    expect(tracks, sendDto.immutableTracks);
  });

  test('pause', () {
    manager.onPlayerStateChanged(PlayerState.PAUSED); // triggered by player callback
    verify(channel.sendPlayerState(PlayerState.PAUSED));
  });

  test('stop', () {
    manager.stop();
    verify(channel.sendPlayerState(PlayerState.ENDED));
  });

  test('Next track', () {
    // execute
    manager.playNext();
    manager.onPlayerStateChanged(PlayerState.BUFFERING); // triggered by player callback

    // validate
    verify(channel.sendPlayerState(PlayerState.BUFFERING));
  });

  test('Prev track', () {
    // execute
    manager.playPrevious();
    manager.onPlayerStateChanged(PlayerState.BUFFERING); // triggered by player callback

    // validate
    verify(channel.sendPlayerState(PlayerState.BUFFERING));
  });

  test('Seek', () {
    // execute
    const seekMs = 0x80;
    manager.setSeek(seekMs);
    manager.onPlayerStateChanged(PlayerState.BUFFERING); // triggered by player callback

    // validate
    verify(channel.sendPlayerState(PlayerState.BUFFERING));
  });

  test('Shuffle', () {
    // execute
    manager.playNext();
    manager.setShuffling(true, SHUFFLE_SEED);

    // validate
    final queue = verify(channel.sendShuffleState(captureAny)).captured[0].value as BasePlaybackQueue;
    final ShuffleStateDto dto = queue.shuffleState;
    expect(true, dto.isShuffled);
    expect(SHUFFLE_SEED, dto.initSeed);
    expect(tracks[1], dto.startTrack);
  });

  test('UnShuffle', () {
    // execute
    manager.playNext();
    manager.setShuffling(true, SHUFFLE_SEED);
    manager.setShuffling(false, SHUFFLE_SEED);

    // validate
    final queue = verify(channel.sendShuffleState(captureAny)).captured[0].value as BasePlaybackQueue;
    final ShuffleStateDto dto = queue.shuffleState;
    expect(false, dto.isShuffled);
  });

  test('Repeating', () {
    // execute
    manager.setRepeating(true);

    // validate
    final queue = verify(channel.sendRepeating(captureAny)).captured[0].value as BasePlaybackQueue;
    expect(true, queue.isRepeating);
  });

  test('UnRepeating', () {
    // execute
    manager.setRepeating(true);
    manager.setRepeating(false);

    // validate
    final queue = verify(channel.sendRepeating(captureAny)).captured[0].value as BasePlaybackQueue;
    expect(false, queue.isRepeating);
  });
}
