import 'package:chrome_tube/playback/playback.dart';
import 'package:chrome_tube/playback/src/ipc/cast_playback_context.dart';
import 'package:mockito/mockito.dart';

class MockedPlaybackManager extends Mock implements PlaybackManager {}

class MockedContext extends Mock implements CastPlaybackContext {}

class MockedUiListener extends Mock implements PlaybackUIListener {}
