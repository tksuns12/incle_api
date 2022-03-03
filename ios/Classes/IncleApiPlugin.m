#import "IncleApiPlugin.h"
#if __has_include(<incle_api/incle_api-Swift.h>)
#import <incle_api/incle_api-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "incle_api-Swift.h"
#endif

@implementation IncleApiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIncleApiPlugin registerWithRegistrar:registrar];
}
@end
