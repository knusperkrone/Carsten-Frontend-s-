@JS('cast.framework')
library cast;

import 'package:js/js.dart';

typedef MessageCallback = void Function(CastReceiveMessage message);
typedef CastEventCallback = void Function(CastEvent event);

@JS()
class CastReceiverContext {
  external static CastReceiverContext getInstance();

  external void addCustomMessageListener(String namespace, MessageCallback callback);
  external void addEventListener(String type, CastEventCallback callback);
  external void start(CastRecevierOptions options);
  external void sendCustomMessage(String name, String id, dynamic msg);
  external List<CastSender> getSenders();
}

/*
 * AddEventListener
 */

@JS()
class CastEvent {
  external String get sessionState;
}

// ignore: avoid_classes_with_only_static_members
@JS()
class SessionState {
  // ignore: non_constant_identifier_names
  external static String get NO_SESSION;
  // ignore: non_constant_identifier_names
  external static String get SESSION_STARTING;
  // ignore: non_constant_identifier_names
  external static String get SESSION_STARTED;
  // ignore: non_constant_identifier_names
  external static String get SESSION_START_FAILED;
  // ignore: non_constant_identifier_names
  external static String get SESSION_ENDING;
  // ignore: non_constant_identifier_names
  external static String get SESSION_ENDED;
  // ignore: non_constant_identifier_names
  external static String get SESSION_RESUMED;
}

/*
 * Start
 */

@JS()
@anonymous
class CastRecevierOptions {
  external factory CastRecevierOptions({bool disableIdleTimeout});

  external bool get disableIdleTimeout;
}

/*
 * I/O
 */

@JS()
@anonymous
class CastReceiveMessage {
  external CastMessage get data;
}

@JS()
@anonymous
class CastMessage {
  external factory CastMessage({String type, dynamic data});
  external String get type;
  external dynamic get data;
}

@JS()
class CastSender {
  external String get id;
}
