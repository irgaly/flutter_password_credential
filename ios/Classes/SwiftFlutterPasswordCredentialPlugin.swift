import Flutter
import UIKit

public class SwiftFlutterPasswordCredentialPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "password_credential", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPasswordCredentialPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "hasCredentialFeature":
            result(true)
            break
        case "get":
            let keyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
            keyStore.synchronize()
            if let storedData = keyStore.dictionaryRepresentation as? [String : String] {
                if storedData.isEmpty {
                    result(nil)
                } else {
                    let encoded = try! JSONEncoder().encode(storedData)
                    result(String(data: encoded, encoding: .utf8))
                }
            } else {
                result(nil)
            }
            break
        case "store":
            let keyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
            
            if let arguments = call.arguments as? [String: String], let credential = arguments["credential"] {
                
                if let data = credential.data(using: .utf8) {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject] {
                            for argument in json {
                                if argument.value is NSNull {
                                    if keyStore.object(forKey: argument.key) != nil {
                                        keyStore.removeObject(forKey: argument.key)
                                    }
                                } else {
                                    keyStore.set(argument.value, forKey: argument.key)
                                }
                            }
                        }
                        if keyStore.synchronize() {
                            result("Success")
                        } else {
                            result("Failure")
                        }
                    } catch {
                        result(nil)
                    }
                }
            
            }
            break
        case "delete":
            let keyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore.default
            keyStore.synchronize()
            let keys = keyStore.dictionaryRepresentation.keys
            for key in keys {
                keyStore.removeObject(forKey: key)
            }
            keyStore.synchronize()
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
}
