# Push Notifications

[← Back to documentation index](../README.md)

> **What this guide covers:** how to give the SDK a device push token so chat replies can be delivered to your users as push notifications.
>
> **Read this when:** you want the user to be notified about new chat activity while the chat UI is not in the foreground.

## How it works

The SDK does **not** request notification permission or manage your APNs or Firebase setup. Your app owns that flow. Your responsibility is to:

1. Register for remote notifications and obtain a push token through APNs or
   Firebase Cloud Messaging.
2. Hand that token to the SDK using `setPushToken(_:)`.
3. Hand the SDK a fresh token whenever it changes (token refresh).

Once the SDK has a valid token, Netomi can route chat notifications to the device.

---

## Prerequisites

- Push notifications enabled for your app, with an APNs key or certificate configured in your Apple Developer account.
- The **Push Notifications** capability added to your app target in Xcode.
- (If using Firebase) the Firebase SDK configured in your app.
- Your Netomi bot configured to send push notifications. Contact Netomi support
  if you are unsure.

> The SDK accepts **either** an APNs device token or a Firebase (FCM) token through the same `setPushToken(_:)` API. Use whichever your app already produces.

---

## Step 1 — Register for notifications in your app

This is standard iOS setup performed by your app. The SDK is not involved yet.

```swift
import UIKit
import UserNotifications

func registerForPushNotifications() {
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    center.requestAuthorization(options: options) { granted, _ in
        guard granted else { return }
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
```

---

## Step 2 — Give the token to the SDK

Pass the token to the SDK as soon as you receive it. Call this **after** `initialize(...)`.

### Using APNs directly

```swift
func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
) {
    let token = deviceToken.map { String(format: "%02x", $0) }.joined()
    NetomiChat.shared.setPushToken(token)
}
```

### Using Firebase Cloud Messaging (FCM)

```swift
import FirebaseMessaging

func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String?
) {
    guard let fcmToken else { return }
    NetomiChat.shared.setPushToken(fcmToken)
}
```

> ✅ `setPushToken(_:)` is the preferred API for **both** APNs and FCM tokens.

---

## Handling token refresh

Push tokens can change after an app reinstall, restored backup, or FCM rotation. Whenever you receive a new token, call `setPushToken(_:)` again with the latest value so notifications keep working.

```swift
// FCM example — fires again automatically when the token rotates.
func messaging(
    _ messaging: Messaging,
    didReceiveRegistrationToken fcmToken: String?
) {
    guard let fcmToken else { return }
    NetomiChat.shared.setPushToken(fcmToken)
}
```

There is no separate "update" call. Calling `setPushToken(_:)` with the new value replaces the previous token.

---

## Deprecated: setFCMToken

```swift
// ❌ Deprecated — do not use in new code.
NetomiChat.shared.setFCMToken("your-fcm-token")
```

> ⚠️ `setFCMToken(_:)` is **deprecated** and forwards to `setPushToken(_:)`. It exists for backward compatibility.
> **Always use `setPushToken(_:)` instead**. It accepts both APNs and FCM tokens.

---

## Troubleshooting

- **Notifications never arrive**
  > Likely cause: token not passed to the SDK. Check that `setPushToken(_:)` is called after `initialize(...)` and after every token refresh.

- **Notifications stop after reinstall**
  > Likely cause: stale token. Check that your token-refresh callback calls `setPushToken(_:)` with the new value.

- **Works in debug, not in production**
  > Likely cause: APNs environment mismatch. Check the APNs key/certificate and environment configured for your bot.

- **Still nothing**
  > Likely cause: bot not configured for push. Confirm with Netomi support that push notifications are enabled for your bot.

---

### ➡️ Related

- Open and manage the chat → **[Usage](usage.md)**
- React to SDK events → **[Events & Authentication](events-and-auth.md)**
- More push help → **[Troubleshooting & FAQ](troubleshooting.md)**
