//
//  AppDelegate.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import UIKit
import UserNotifications
import Netomi

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    override init() {
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    /// Requests push notification authorization and registers with APNs.
    /// Call this if your app supports push notifications; forward the resulting
    /// device token to `NetomiChat.shared.setPushToken(_:)`.
    private func setupPushNotifications(_ application: UIApplication) {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: authOptions) { (granted, _) in
            guard granted else { return }
            DispatchQueue.main.async {
                center.delegate = self
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        application.registerForRemoteNotifications()
    }

    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NetomiChat.shared.setPushToken(token)
    }
}

