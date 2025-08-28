import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.yourapp.receipt", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { call, result in
        if call.method == "verifyReceipt" {
            ReceiptVerifier.shared.verifyReceipt { jsonString in
                result(jsonString)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
