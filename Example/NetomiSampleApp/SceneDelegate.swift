//
//  SceneDelegate.swift
//  NetomiSampleApp
//
//  Created by Netomi on 14/11/24.
//

import UIKit
import Netomi

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let _ = (scene as? UIWindowScene) else { return }
        UNUserNotificationCenter.current().delegate = self        
        handleScreen()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private func handleScreen() {
        if Defaults.isLoggedIn {
            SceneDelegate.moveToHome()
        }
    }
    
    static func moveToHome() {
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                let nav = UINavigationController(rootViewController: vc)
                sceneDelegate.window?.rootViewController = nav
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    // Handle notification when app is in foreground
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
        ) {
            completionHandler([.banner, .sound, .badge])
        }

        // Handle notification tap action
        func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void
        ) {
            let userInfo = response.notification.request.content.userInfo
            print("User tapped notification: \(userInfo)")
            completionHandler()
        }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else { return }
        handleDeepLink(url: url)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleDeepLink(url: url)
    }
    
    private func handleDeepLink(url: URL) {
        guard let host = url.host else { return }

        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }

        guard let rootVC = window.rootViewController else { return }

        // Find the top-most view controller (even if it's in another window)
        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            if let coveringWindow = sceneDelegate.window?.windowScene?.windows.first(where: { $0.windowLevel == .alert + 1 }) {
                coveringWindow.isHidden = true
                coveringWindow.rootViewController = nil
            }
        }
        
        // Force dismiss any modally presented view controller
        if topVC != rootVC {
            topVC.dismiss(animated: true) {
                self.navigateToDeepLinkScreen(url: url, navController: self.getNavController(from: rootVC))
            }
        } else {
            self.navigateToDeepLinkScreen(url: url, navController: self.getNavController(from: rootVC))
        }
    }

    // Helper function to get UINavigationController
    private func getNavController(from rootVC: UIViewController) -> UINavigationController? {
        if let nav = rootVC as? UINavigationController {
            return nav
        } else if let tabBarController = rootVC as? UITabBarController,
                  let selectedNav = tabBarController.selectedViewController as? UINavigationController {
            return selectedNav
        } else {
            return nil
        }
    }

    // Function to navigate after dismissal
    private func navigateToDeepLinkScreen(url: URL, navController: UINavigationController?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var nextVC: UIViewController?

        switch url.lastPathComponent {
        case "screen1":
            nextVC = storyboard.instantiateViewController(withIdentifier: "DeeplinkingexampleFirstVC") as? DeeplinkingexampleFirstVC
        case "screen2":
            nextVC = storyboard.instantiateViewController(withIdentifier: "DeeplinkingexampleSecondVC") as? DeeplinkingexampleSecondVC
        default:
            print("⚠️ Unknown deep link: \(url.lastPathComponent)")
            return
        }

        if let nextVC = nextVC, let navController = navController {
            navController.pushViewController(nextVC, animated: true)
        } else {
            print("⚠️ Failed to instantiate or navigate to ViewController for \(url.lastPathComponent)")
        }
    }
}

