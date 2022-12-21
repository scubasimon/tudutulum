import UIKit
import Flutter
import GoogleMaps
import flutter_local_notifications
import background_location_tracker

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GMSServices.provideAPIKey("AIzaSyC0X1LsGOoWFNOj6Nn3zUlw9DtTwJdn2Ts")
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
              GeneratedPluginRegistrant.register(with: registry)
          }
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

      GeneratedPluginRegistrant.register(with: self)
      BackgroundLocationTrackerPlugin.setPluginRegistrantCallback { registry in
                 GeneratedPluginRegistrant.register(with: registry)
             }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
