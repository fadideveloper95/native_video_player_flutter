import Foundation
import Flutter

class NativeVideoRegistry {
    static var views: [Int: NativeVideoView] = [:]
}

class NativeVideoEventBus {
    static var channel: FlutterMethodChannel?
    static func emit(_ method: String = "event", _ args: [String: Any]) {
        channel?.invokeMethod(method, arguments: args)
    }
}
