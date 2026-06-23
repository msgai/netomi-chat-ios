# Advanced

[← Back to documentation index](../README.md)

> **What this guide covers:** optional controls beyond the basic launch flow: tracking consent, custom menus, custom parameters, API headers, audio session behavior, and logging.
>
> **Read this when:** the [Usage](usage.md) flow works, but you need extra control over a specific behavior.
>
> 💡 Each section below is **independent and optional**. Use only the sections relevant to your app. Looking for **push notifications**? See **[Push Notifications](push-notifications.md)**.

---

## 🔒 Tracking Consent

Use `setTrackingConsent(_:)` when your app needs to control SDK observability consent at runtime. For example, use it to honor a user's privacy choice.

```swift
NetomiChat.shared.setTrackingConsent(.granted)
```

Common values are `.granted`, `.notGranted`, and `.pending`.

---

## 🧩 Configure Initial Menu

Use `setInitialMenu(_:)` when your app needs to override the server-configured initial menu at runtime. Call it **before** launching the chat.

```swift
let initialMenu = NCWInitialMenuConfiguration(
    header: "How can we help you?",
    menuItems: [
        NCWInitialMenuItem(
            name: "track_order",
            label: "Track Order"
        ),
        NCWInitialMenuItem(
            name: "refund_order",
            label: "Refund Order"
        )
    ]
)

NetomiChat.shared.setInitialMenu(initialMenu)
NetomiChat.shared.launch()
```

- `header`: Text displayed above the initial menu items.
- `menuItems`: Menu items shown in the chat. Each item requires:
  - `name`: Unique identifier or event name associated with the menu item.
  - `label`: User-visible text displayed for the menu item.
- The override is applied during chat launch. It does not update an already visible chat session.
- Pass `nil` or call `clearInitialMenu()` to remove the override and fall back to the server configuration.

```swift
NetomiChat.shared.clearInitialMenu()
// or
NetomiChat.shared.setInitialMenu(nil)
```

---

## 🧩 Send Custom Parameters

Use custom parameters to personalize the chat experience or pass session-specific metadata to the AI backend.

### 🔹 Send a single key-value parameter

```swift
// Example: Indicate that the current user is a premium member
NetomiChat.shared.sendCustomParameter(name: "user_role", value: "premium_user")
```

### 🔹 Set multiple custom parameters at once

```swift
// Example: Pass user profile info during initialization
let userAttributes: [String: String] = [
  "user_id": "12345",                // Unique ID of the user
  "user_name": "John Doe",           // Optional full name
  "membership_level": "gold",        // Tier of user (e.g., gold, silver)
  "app_version": "7.2.0"             // App version for debugging or targeting
]

NetomiChat.shared.setCustomParameter(userAttributes)
```

---

## 🧾 Pass Custom API Headers (Optional)

Send custom HTTP headers with each SDK API request. This is useful for authentication tokens, versioning, experiment targeting, or localization context.

```swift
let customHeaders: [String: String] = [
  "X-App-Version": "7.2.0",                       // Current app version
  "X-Device-ID": "device-98765",                  // Unique device identifier
  "X-Platform": "iOS",                            // OS platform info
  "X-User-Type": "beta_tester",                   // User group/segment
  "X-Experiment-Variant": "A",                    // A/B test group
  "X-Locale": Locale.current.identifier           // e.g., "en_US"
]

NetomiChat.shared.updateApiHeaderConfiguration(headers: customHeaders)
```

> ⚠️ These headers are automatically sent with each SDK API call.
> Do not include sensitive data such as passwords or secrets.

---

## 🔊 Configure Audio Session (Optional)

The SDK manages audio session behavior for voice features by default. If your app owns `AVAudioSession`, configure this before launching chat.

```swift
NetomiChat.shared.configureAudioSession(
    forceSpeakerOutput: true,
    disableSessionControl: false
)
```

- `forceSpeakerOutput`: Routes audio to speaker when no Bluetooth or wired output is connected.
- `disableSessionControl`: Set to `true` when your app manages audio activation and deactivation itself.

---

## 🔍 Enable Logging

You can set the log level at any time during app runtime. Keep logging off (`.none`) in production.

```swift
#if DEBUG
NetomiChat.shared.setupLogging(level: .info)
#endif
```

### 📚 Available Log Levels

| Level | Description |
| --- | --- |
| `.none` | No logs will be printed (recommended for production). |
| `.error` | Prints only SDK-related public error logs. |
| `.info` | Prints public informational and error logs. |

> **Default:** `.none`

---

### ➡️ Related

- Core launch & lifecycle → **[Usage](usage.md)**
- Push notification setup → **[Push Notifications](push-notifications.md)**
- JWT auth and events → **[Events & Authentication](events-and-auth.md)**
- Consent, privacy manifest, secrets → **[Security & Privacy](security-and-privacy.md)**
- Something not working? → **[Troubleshooting & FAQ](troubleshooting.md)**
