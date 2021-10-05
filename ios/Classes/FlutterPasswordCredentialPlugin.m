#import "FlutterPasswordCredentialPlugin.h"
#if __has_include(<flutter_password_credential/flutter_password_credential-Swift.h>)
#import <flutter_password_credential/flutter_password_credential-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_password_credential-Swift.h"
#endif

@implementation FlutterPasswordCredentialPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPasswordCredentialPlugin registerWithRegistrar:registrar];
}
@end
