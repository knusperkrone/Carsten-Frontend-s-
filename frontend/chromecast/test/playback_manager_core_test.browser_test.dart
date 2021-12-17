import 'package:mockito/mockito.dart';
import 'package:playback_caf_dart/playback_caf.dart';
import 'package:playback_caf_dart/src/playback/ui_manager.dart';
import 'package:playback_core/playback_core.dart';
import 'package:playback_core/src_test/constant.dart';
import 'package:playback_core/src_test/generator.dart';
import 'package:test/test.dart';

class MockedUI extends Mock implements UiManager {}

class MockedBridge extends Mock implements CommunicationChannel {}

class MockedPlayer extends Mock implements PlaybackPlayer {}

void main() {
  late List<PlaybackTrack> tracks;
  late PlaybackManager manager;
  late MockedPlayer player;

  setUp(() {
    player = new MockedPlayer();
    manager = new PlaybackManager(MockedBridge(), MockedUI());
    manager.onPlayerReady(player);

    // Pre-execute
    tracks = generateTracks();
    manager.appendToQueue([new PlaybackTrack.dtoHack(0, '')]);
    manager.appendToQueue(tracks);
    manager.appendToQueue([]);
  });

  test('On tracks', () {
    // validate
    final queue = manager.TEST_queue;
    expect(tracks[0], queue.currentTrack);
    verify(player.playTrack(tracks[0])).called(1);
  });

  test('Play', () {
    manager.play();
    verify(player.play()).called(1);
  });

  test('pause', () {
    manager.pause();
    verify(player.pause()).called(1);
  });

  test('stop', () {
    manager.stop();
    verify(player.stop()).called(1);
  });

  test('Next track', () {
    // execute
    manager.playNext();

    // validate
    final queue = manager.TEST_queue;
    expect(tracks[1], queue.currentTrack);
    verify(player.playTrack(tracks[1])).called(1);
  });

  test('Prev track', () {
    // execute
    manager.playNext();
    manager.playPrevious();

    // validate
    final queue = manager.TEST_queue;
    expect(tracks[0], queue.currentTrack);
    verify(player.playTrack(tracks[0])).called(2);
  });

  test('Seek', () {
    // execute
    const seekMs = 0x80;
    manager.setSeek(seekMs);

    // validate
    verify(player.seekTo(seekMs)).called(1);
  });

  test('Shuffle', () {
    // execute
    manager.setShuffling(true, SHUFFLE_SEED);

    // validate
    final queue = manager.TEST_queue;
    expect(true, queue.isShuffled);
    expect(EXPECTED_SHUFFLED_MANAGER, tracksToString(queue.mutableTracks));
  });

  test('UnShuffle', () {
    // execute
    manager.setShuffling(true, SHUFFLE_SEED);
    manager.setShuffling(false);

    // validate
    final queue = manager.TEST_queue;
    expect(false, queue.isShuffled);
    expect(tracksToString(tracks), tracksToString(queue.mutableTracks));
  });

  test('Repeating', () {
    // execute
    manager.setRepeating(true);

    // validate
    final queue = manager.TEST_queue;
    expect(true, queue.isRepeating);
  });

  test('UnRepeating', () {
    // execute
    manager.setRepeating(true);
    manager.setRepeating(false);

    // validate
    final queue = manager.TEST_queue;
    expect(false, queue.isRepeating);
  });

  test('PlayTrack', () {
    // execute
    final playTrack = new PlaybackTrack.dummy(isPrio: true);
    manager.playTrack(playTrack);

    // validate
    final queue = manager.TEST_queue;
    expect(playTrack, queue.currentTrack);

    manager.playNext();
    expect(tracks[1], queue.currentTrack);
  });

  test('PlayTrack - empty', () {
    // execute
    final playTrack = new PlaybackTrack.dummy(isPrio: true);
    manager.playTrack(playTrack);

    // validate
    final queue = manager.TEST_queue;
    expect(playTrack, queue.currentTrack);

    manager.playNext();
    expect(tracks[1], queue.currentTrack);
  });
}
