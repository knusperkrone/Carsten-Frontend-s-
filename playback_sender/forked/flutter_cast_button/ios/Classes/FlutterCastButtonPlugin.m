#import "FlutterCastButtonPlugin.h"
#if __has_include(<flutter_cast_button/flutter_cast_button-Swift.h>)
#import <flutter_cast_button/flutter_cast_button-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_cast_button-Swift.h"
#endif

@implementation FlutterCastButtonPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCastButtonPlugin registerWithRegistrar:registrar];
}
@end
