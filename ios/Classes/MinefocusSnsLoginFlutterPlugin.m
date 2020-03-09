#import "MinefocusSnsLoginFlutterPlugin.h"
#if __has_include(<minefocus_sns_login_flutter/minefocus_sns_login_flutter-Swift.h>)
#import <minefocus_sns_login_flutter/minefocus_sns_login_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "minefocus_sns_login_flutter-Swift.h"
#endif

@implementation MinefocusSnsLoginFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMinefocusSnsLoginFlutterPlugin registerWithRegistrar:registrar];
}
@end
