import Flutter
import UIKit

public class SwiftFlutterPasswordCredentialPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_password_credential", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPasswordCredentialPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
