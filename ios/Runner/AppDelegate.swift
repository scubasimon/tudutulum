import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
        GMSServices.provideAPIKey("AIzaSyC0X1LsGOoWFNOj6Nn3zUlw9DtTwJdn2Ts")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
