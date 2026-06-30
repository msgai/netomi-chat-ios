# Troubleshooting & FAQ

[← Back to documentation index](../README.md)

> **What this guide covers:** common integration issues, how to debug them, and answers to frequently asked questions.
>
> **Read this when:** something is not working as expected, or you want a quick answer before reading a full guide.

---

## 🔍 Debugging guidance

Before diving into a specific symptom, turn on logging and observe SDK events. These two signals explain most issues.

### 1. Enable logging (debug builds only)

```swift
#if DEBUG
NetomiChat.shared.setupLogging(level: .info)
#endif
```

| Level | Use |
| --- | --- |
| `.none` | Production default — no logs. |
| `.error` | Public SDK error logs only. |
| `.info` | Public info + error logs — best for development. |

> Keep logging at `.none` in production builds.

### 2. Observe SDK events (including errors)

Subscribe to `getEventUpdatesFromSDK` and inspect the `.error` event. The error text is available under the `error_details` key.

```swift
NetomiChat.shared.getEventUpdatesFromSDK = { event in
    guard let type = event[NCWPublicEventKeys.eventType.rawValue] as? String,
          let eventType = NCWPublicEvent(rawValue: type) else { return }

    if eventType == .error {
        let data = event[NCWPublicEventKeys.eventData.rawValue] as? [String: Any] ?? [:]
        print("SDK error:", data[NCWPublicEventKeys.errorDetails.rawValue] ?? data)
    }
}
```

### 3. Inspect launch failures

`launch` accepts an optional `errorHandler` that is invoked **only when the chat cannot be shown**. The handler receives an `NCWErrorData` value with a status code and message.

```swift
NetomiChat.shared.launch(
    jwt: nil,
    errorHandler: { error in
        print("Chat launch failed:", error)
    }
)
```

> The async variants (`launchAsync` / `launchWithQueryAsync`) return `false` when the chat could not be presented at this time.

---

## 🛠 Common issues

| Symptom | Likely cause | Resolution |
| --- | --- | --- |
| Chat won't launch, or `launchAsync` returns `false` | SDK not initialized, invalid `botRefId`/`env`, or bot config could not be fetched | Confirm `initialize(...)` ran with valid credentials before `launch()`. Pass an `errorHandler` to `launch` and inspect `NCWErrorData`. Set log level to `.info`. |
| No bot messages arrive | Real-time connection or session not established (network/auth) | Check device connectivity. For authenticated bots, confirm the JWT flow. Watch for the `.error` event and review `.info` logs. |
| Reauthorization keeps repeating | Missing or expired JWT on `.reauthorizationSuccess` | Respond to `.reauthorizationRequest` with a **fresh, valid** JWT via `sendEventToSdk(type: .reauthorizationSuccess, jwt:)`. See [Events & Authentication](events-and-auth.md). |
| `sendEventToSdk(...)` throws | Missing JWT, missing/duplicate custom event name, or non-JSON payload | Handle `NetomiEventError`: provide a JWT for `.reauthorizationSuccess`, give a non-reserved `eventName` for `.custom`, and ensure `data` is JSON-serializable. |
| UI theming not applied | `update*Configuration(...)` called **after** `launch()` | Apply all theming overrides **before** `launch()`. See [UI Theming](ui-theming.md). |
| Push notifications never arrive | Token not handed to the SDK, stale token, or bot not configured for push | Call `setPushToken(_:)` after `initialize(...)` and on every token refresh. See [Push Notifications](push-notifications.md). |
| Build error: duplicate or missing `Datadog` / `Lottie` / `Mixpanel` symbols | A managed dependency was added manually, or analytics was not enabled | Remove manually added copies of managed dependencies. For analytics, add `NetomiAnalytics` (SPM) or `NetomiChatSDK/Analytics` (CocoaPods) and call `NetomiAnalyticsSupport.enable()`. See [Installation](installation.md). |
| Swift Package Manager checksum mismatch | Cached or mismatched package resolution | In Xcode, **File → Packages → Reset Package Caches**, then resolve again on the intended version tag. |
| Voice features have no audio, or conflict with your audio | Your app and the SDK are both managing `AVAudioSession` | If your app owns the audio session, call `configureAudioSession(...)`. See [Advanced](advanced.md). |
| Both CocoaPods and SPM added in one target | The SDK was integrated twice | Use **one** integration method per app target, never both. See [Installation](installation.md). |

---

## ❓ Frequently asked questions

### Installation & setup

**Which should I use, Swift Package Manager or CocoaPods?**
Swift Package Manager is the recommended long-term path for new integrations. CocoaPods is still supported. Use only one method per app target. See [Installation](installation.md).

**Do I need to add AWS, Microsoft Speech, Datadog, or Lottie myself?**
No. `NetomiChatSDK` manages those dependencies for you. Adding them manually can cause duplicate-symbol build errors.

**When is Mixpanel (analytics) included?**
Only when you opt in — add the `NetomiAnalytics` product (SPM) or the `NetomiChatSDK/Analytics` subspec (CocoaPods) and call `NetomiAnalyticsSupport.enable()`.

**Does the SDK support both UIKit and SwiftUI?**
Yes, both are supported.

**What is the minimum iOS version?**
iOS 16 or later, built with Xcode 26+. See [Installation](installation.md).

### Initialization & launch

**Do I need to call `initialize(...)` more than once?**
No. Call it once at app startup. The SDK safely ignores duplicate calls that use the same `botRefId`, `env`, and `isDynamicEnv`. Changing any of those resets state and re-initializes.

**Should I gate `launch()` behind `isInitialized(...)`?**
No. The SDK handles repeated calls and internal state. Use `isInitialized(...)` only if your app specifically needs to check the current configuration.

**When should I use `launchAsync` instead of `launch`?**
Use `launchAsync` only when your app needs to know whether the chat UI was actually shown. Otherwise prefer the fire-and-forget `launch()`.

### Authentication & users

**Is a JWT required?**
Only if your bot is configured for authenticated sessions. Otherwise pass `nil` (or omit it) for a guest session. A JWT passed to a non-authenticated bot is safely ignored. See [Events & Authentication](events-and-auth.md).

**How do I switch users or handle logout?**
Call `clearChatSession()` to end any active conversation, dismiss the chat UI if visible, and clear the stored session state. Then launch again with the new user's JWT (authenticated) or without one (guest).

**Can I attach my own user attributes?**
Yes, with `setCustomParameter(_:)` / `sendCustomParameter(name:value:)`. These are metadata only — they do not authenticate the user. Do not put secrets in custom parameters or API headers.

### Notifications & customization

**Why aren't push notifications working?**
Most often the token was not handed to the SDK, or it went stale. Call `setPushToken(_:)` after `initialize(...)` and on every refresh. See [Push Notifications](push-notifications.md).

**My theming changes don't show up. Why?**
UI customization must be applied **before** `launch()`. Changes made while the chat is already visible are not guaranteed to take effect on the current session. See [UI Theming](ui-theming.md).

**Can I change the chat's language?**
Localized strings are driven by your bot configuration in the Netomi Dashboard. The SDK renders the configured language; there is no separate string-override API in the app.

---

## 🆘 Still stuck?

If logging and the steps above don't resolve the issue, contact Netomi support with:

- Your SDK version and integration method (SPM or CocoaPods).
- The `botRefId` and `env` you initialize with.
- Relevant `.info`-level logs and any `.error` event `error_details`.

- 📘 [Netomi Website](https://www.netomi.com)
- 📩 [support@netomi.com](mailto:support@netomi.com)

---

### ➡️ Related

- Add the SDK to your project → **[Installation](installation.md)**
- Core launch & lifecycle → **[Usage](usage.md)**
- JWT auth and events → **[Events & Authentication](events-and-auth.md)**
- Push notification setup → **[Push Notifications](push-notifications.md)**
- Consent, privacy manifest, secrets → **[Security & Privacy](security-and-privacy.md)**
