import UIKit
import Flutter

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    if let registrar = controller.registrar(forPlugin: "NativeVideoPlugin") {
        registrar.register(NativeVideoViewFactory(messenger: registrar.messenger()), withId: "NativeVideoView")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
