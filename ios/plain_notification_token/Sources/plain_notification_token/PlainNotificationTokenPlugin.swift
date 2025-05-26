import Flutter
import UIKit
import UserNotifications

public class PlainNotificationTokenPlugin: NSObject, FlutterPlugin {
  private var channel: FlutterMethodChannel?
  private var lastToken: String?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "plain_notification_token", binaryMessenger: registrar.messenger())
    let instance = PlainNotificationTokenPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addApplicationDelegate(instance)

    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        let settingsDict: [String: Bool] = [
          "sound": settings.soundSetting == .enabled,
          "badge": settings.badgeSetting == .enabled,
          "alert": settings.alertSetting == .enabled
        ]
        channel.invokeMethod("onIosSettingsRegistered", arguments: settingsDict)
      }
    }
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getToken":
      result(lastToken)
    case "requestPermission":
      if let settings = call.arguments as? [String: Bool] {
        requestPermission(settings: settings)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestPermission(settings: [String: Bool]) {
    if #available(iOS 10.0, *) {
      var options: UNAuthorizationOptions = []
      if settings["sound"] == true { options.insert(.sound) }
      if settings["badge"] == true { options.insert(.badge) }
      if settings["alert"] == true { options.insert(.alert) }

      UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, error in
        if let error = error {
          print("Error requesting permission: \(error)")
        }
        if granted {
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }
          self.channel?.invokeMethod("onIosSettingsRegistered", arguments: settings)
        } else {
          let deniedSettings: [String: Bool] = ["sound": false, "badge": false, "alert": false]
          self.channel?.invokeMethod("onIosSettingsRegistered", arguments: deniedSettings)
        }
      }
    } else {
      var types: UIUserNotificationType = []
      if settings["sound"] == true { types.insert(.sound) }
      if settings["badge"] == true { types.insert(.badge) }
      if settings["alert"] == true { types.insert(.alert) }

      let notificationSettings = UIUserNotificationSettings(types: types, categories: nil)
      UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
  }
}

// MARK: - AppDelegate methods

extension PlainNotificationTokenPlugin: FlutterApplicationLifeCycleDelegate {
  public func application(_ application: UIApplication,
                          didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    self.lastToken = token
    self.channel?.invokeMethod("onToken", arguments: token)
  }

  public func application(_ application: UIApplication,
                          didRegister notificationSettings: UIUserNotificationSettings) {
    let settingsDict: [String: Bool] = [
      "sound": notificationSettings.types.contains(.sound),
      "badge": notificationSettings.types.contains(.badge),
      "alert": notificationSettings.types.contains(.alert)
    ]
    self.channel?.invokeMethod("onIosSettingsRegistered", arguments: settingsDict)
  }
}
