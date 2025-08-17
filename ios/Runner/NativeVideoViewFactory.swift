import Flutter
import UIKit

class NativeVideoViewFactory: NSObject, FlutterPlatformViewFactory {
    private var channel: FlutterMethodChannel!
    init(messenger: FlutterBinaryMessenger) {
        super.init()
        channel = FlutterMethodChannel(name: "native_video/channel", binaryMessenger: messenger)
        channel.setMethodCallHandler(handle)
        NativeVideoEventBus.channel = channel
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol { return FlutterStandardMessageCodec.sharedInstance() }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let dict = args as? [String: Any]
        let logicalId = (dict?["id"] as? Int) ?? Int(viewId)
        let view = NativeVideoView(frame: frame)
        view.logicalId = logicalId
        NativeVideoRegistry.views[logicalId] = view
        return view
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any], let id = args["id"] as? Int, let view = NativeVideoRegistry.views[id] else {
            result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found", details: nil)); return
        }
        switch call.method {
        case "register":
            let url = args["url"] as? String ?? ""
            let autoPlay = args["autoPlay"] as? Bool ?? false
            let loop = args["loop"] as? Bool ?? false
            let volume = args["volume"] as? Double ?? 1.0
            let muted = args["muted"] as? Bool ?? false
            view.prepare(url: url, autoPlay: autoPlay, loop: loop, volume: Float(volume), muted: muted)
            result(nil)
        case "play":
            view.play(); result(nil)
        case "pause":
            view.pause(); result(nil)
        case "seekTo":
            let ms = args["ms"] as? Int ?? 0
            view.seekTo(milliseconds: ms); result(nil)
        case "setVolume":
            let volume = args["volume"] as? Double ?? 1.0
            view.setVolume(Float(volume)); result(nil)
        case "setMuted":
            let muted = args["muted"] as? Bool ?? false
            view.setMuted(muted); result(nil)
        case "dispose":
            view.dispose()
            NativeVideoRegistry.views.removeValue(forKey: id)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
