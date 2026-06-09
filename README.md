# Netomi Mobile Chat SDK (iOS)

## Overview

The **Netomi iOS Chat SDK** allows you to embed conversational AI into your app. It supports:

- Rich media responses
- File attachments and forms
- Live agent handoff
- Firebase push notifications
- Flexible UI styling (via code or Netomi dashboard)

---

## Prerequisites

- iOS 16 or later
- Xcode 26+
- UIKit or SwiftUI (both supported by the SDK)
- CocoaPods or Swift Package Manager. Manual framework integration is not supported because the SDK depends on runtime-managed third-party packages.
- Your Bot Credentials from Netomi (`botRefId`, `environment`)

> **Important:** Use either CocoaPods or Swift Package Manager for a given app target, not both. Do not add AWS, Microsoft Speech, Datadog, Lottie, or Netomi binary frameworks manually when using `NetomiChatSDK`; the package/pod manages those dependencies for you.

---

## Installation

### 1️⃣ CocoaPods

1. Add this to your `Podfile`:

   ```ruby
   # Base SDK without optional analytics
   pod 'NetomiChatSDK', '1.24.5'

   # Or, opt in to optional analytics support. Mixpanel is the currently included provider.
   # pod 'NetomiChatSDK/Analytics', '1.24.5'
   ```

2. Run:

   ```bash
   pod install
   ```

3. Open `.xcworkspace` in Xcode.

4. ✅ **Required Third-Party Dependencies**

   CocoaPods installs AWS IoT Core, Microsoft Cognitive Services Speech SDK, Datadog, and Lottie automatically through `NetomiChatSDK`. Mixpanel is installed only when the `Analytics` subspec is selected.

5. Import and Use

    ```swift
    import Netomi

    // Required only when using NetomiChatSDK/Analytics.
    NetomiAnalyticsSupport.enable()
    ```

> **Note:** CocoaPods has announced a read-only test window from **November 1-7, 2026**, followed by the permanent Trunk read-only switch on **December 2, 2026**.
>
> - Existing published versions of `NetomiChatSDK` should remain installable.
> - Publishing automation may fail during the November 1-7, 2026 test window.
> - New `NetomiChatSDK` podspec versions will no longer be publishable to Trunk after December 2, 2026.
> - For new integrations, **Swift Package Manager is the recommended long-term installation path**.
>
> Reference: <https://blog.cocoapods.org/CocoaPods-Specs-Repo/>

---

### 2️⃣ Swift Package Manager (SPM)

1. Go to **Xcode > Project > Package Dependencies**
2. Add repository:

   ```text
   https://github.com/msgai/netomi-chat-ios.git
   ```

3. Select tag or branch: `1.24.5`

4. Choose package products:

   - Add `Netomi` for the base SDK without optional analytics.
   - Add both `Netomi` and `NetomiAnalytics` to opt in to optional analytics support. Mixpanel is the currently included provider.

   The `Netomi` product links AWS IoT Core, Microsoft Cognitive Services Speech SDK, Datadog, and Lottie automatically. Mixpanel is linked only when `NetomiAnalytics` is selected.

5. Import and Use

    ```swift
    import Netomi

    // Required only when the NetomiAnalytics product is selected.
    import NetomiAnalytics
    NetomiAnalyticsSupport.enable()
    ```

---

### Managed Dependency Versions

`NetomiChatSDK` manages the following third-party dependencies:

| Dependency                                | Version Range     |
|-------------------------------------------|-------------------|
| AWS IoT Core                              | `2.41.0..<2.42.0` |
| Microsoft Cognitive Services Speech SDK   | `1.49.1`          |
| Datadog Core / Logs                       | `3.11.0..<3.12.0` |
| Lottie                                    | `4.6.0..<4.7.0`   |
| Mixpanel Swift (optional)                 | `6.4.0..<7.0.0`   |

Do not add separate versions of these dependencies unless Netomi support asks you to do so. Lottie is part of Core; Mixpanel is not installed unless the optional analytics product or subspec is selected.

---

## Quick Start

### ✅ Initialize SDK

Initialize the SDK once with your bot reference ID and environment before launching chat.

```swift
NetomiChat.shared.initialize(
    botRefId: "YOUR_BOT_REF_ID",
    env: .USProd
)
```

- `botRefId`: Your Netomi bot reference ID.
- `env`: Netomi environment. Supported values: `.USProd`, `.SGProd`, `.EUProd`, `.QA`, `.QAInternal`, `.Development`.
- `isDynamicEnv`: Optional. Pass `true` only when your bot is configured for dynamic SDK configuration.

```swift
NetomiChat.shared.initialize(
    botRefId: "YOUR_BOT_REF_ID",
    env: .QA,
    isDynamicEnv: true
)
```

> The SDK safely ignores duplicate initialization calls for the same `botRefId`, `env`, and `isDynamicEnv`.
> If any of these values change, the SDK resets the current SDK state and initializes for the new configuration.
>
> 🔹 Most visual styling can be configured via the Netomi Dashboard.
>
> 🔹 If you'd like to customize it locally in code, see [Apply UI Customization](#-apply-ui-customization-optional)

---

### (Optional) Check Initialization State

Use `isInitialized(botRefId:environment:isDynamicEnv:)` only when your app needs to check whether the SDK is already initialized for a specific configuration.

```swift
let isReady = NetomiChat.isInitialized(
    botRefId: "YOUR_BOT_REF_ID",
    environment: .USProd
)
```

For dynamic environment mode, pass the same `isDynamicEnv` value used during initialization:

```swift
let isReady = NetomiChat.isInitialized(
    botRefId: "YOUR_BOT_REF_ID",
    environment: .QA,
    isDynamicEnv: true
)
```

- Returns `true` only when the SDK was initialized with the same `botRefId`, `environment`, and `isDynamicEnv`.
- Returns `false` if any value is different. For example, if you initialized with `isDynamicEnv: false`, checking with `isDynamicEnv: true` returns `false`.
- Do **not** gate `initialize()` or `launch()` based on this. The SDK safely handles repeated calls.

---

### 🚀 Launch Chat

Open the chat directly or with an optional prefilled query.
You can also customize the **animation style and duration** using `NCWAnimationConfig`.
If using a custom initial menu, call `setInitialMenu(_:)` before launching the chat.

> ℹ️ Launch APIs are **fire-and-forget by default**.
> Use `launchAsync()` only if you need confirmation.

---

### 🔹 Basic (Recommended)

```swift
NetomiChat.shared.launch()
```

Use this in most cases.
The SDK handles all internal validation and state management.

---

### 🔹 With Optional Error Handling

```swift
NetomiChat.shared.launch(
    jwt: nil,
    errorHandler: { error in
        print("Chat launch failed:", error)
    }
)
```

- `errorHandler` is invoked **only if the chat cannot be shown**
- It is **not** a completion callback

---

### 🔹 With Initial Query

```swift
NetomiChat.shared.launchWithQuery(
    "Hello, I need help",
    jwt: nil
)
```

---

### 🔹 With Custom Animation

```swift
let animation = NCWAnimationConfig(
    animationType: .fade,
    duration: 0.35
)

NetomiChat.shared.launch(
    jwt: nil,
    animationConfig: animation
)
```

---

### 🔹 With Query + Custom Animation

```swift
let animation = NCWAnimationConfig(animationType: .fade, duration: 0.35)

NetomiChat.shared.launchWithQuery(
    "Hello, I need help",
    jwt: nil,
    animationConfig: animation
)
```

---

### ⚙️ Animation Config

|Option|Description|Default|
|------|-----------|-------|
|`animationType`|`.system` (slide), `.fade`, or other supported preset|`.system`|
|`duration`|Duration of the animation in seconds|`0.3`|

---

## 🔹 `launchAsync` (Advanced)

Use this **only if your app needs to know whether the chat UI was shown**.

```swift
let launched = await NetomiChat.shared.launchAsync(
    jwt: nil,
    animationConfig: NCWAnimationConfig(animationType: .fade)
)

if launched {
    print("Chat launched successfully")
}
```

### Return Value

|Value|Meaning|
|-----|-------|
|`true`|Chat UI was presented|
|`false`|Chat could not be presented|

> ℹ️ A `false` return simply means the SDK was unable to show the chat **at this time**.
> The SDK internally handles validation, retries, and state coordination.

---

### 🔐 JWT Authentication (Optional)

```swift
NetomiChat.shared.launch(jwt: "your-jwt-token")
```

- JWT is required **only** if your bot is configured for authenticated sessions
- Passing a JWT when not required is safely ignored

---

### 🔐 JWT Token Usage

|Use Case|JWT Required|Notes|
|--------|------------|-----|
|`launch(jwt:)`|❌ Optional|Use if your bot requires authentication; otherwise pass `nil`.|
|`launchWithQuery(_:jwt:)`|❌ Optional|Same as above.|
|`launchAsync(jwt:)`|❌ Optional|Async variant of `launch`. Returns whether the chat UI was shown.|
|`launchWithQueryAsync(_:jwt:)`|❌ Optional|Async variant with a prefilled query.|
|`.reauthorizationSuccess`|✅ Required|Must provide a valid JWT if the session was started with JWT.|
|`.reauthorizationFailure`|❌ Optional|You can omit JWT here.|
|Other events|❌ Optional|JWT is ignored if provided.|

---

### 🔹 Async Launch Examples

#### Await Chat Launch

```swift
let launched = await NetomiChat.shared.launchAsync(
    jwt: nil,
    animationConfig: NCWAnimationConfig(animationType: .fade)
)

if launched {
    print("Chat launched")
}
```

#### Await Launch With Query

```swift
let launched = await NetomiChat.shared.launchWithQueryAsync(
    "Hello, I need help",
    jwt: nil
)
```

> ℹ️ Async APIs are **optional** and intended for cases where your app needs to
> confirm whether the chat UI was presented.
> The SDK manages all internal validation and state automatically.

---

### 🧩 Clear Current Chat Session Manually

```swift
NetomiChat.shared.clearChatSession()
```

---

### 🔒 Tracking Consent

Use `setTrackingConsent(_:)` if your app needs to control SDK observability consent at runtime.

```swift
NetomiChat.shared.setTrackingConsent(.granted)
```

Common values are `.granted`, `.notGranted`, and `.pending`.

---

### 🧩 Configure Initial Menu

Use `setInitialMenu(_:)` when your app needs to override the server-configured initial menu at runtime.
Call it before launching the chat.

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
- The override is applied during chat launch and does not update an already visible chat session.
- Pass `nil` or call `clearInitialMenu()` to remove the override and fall back to the server configuration.

```swift
NetomiChat.shared.clearInitialMenu()
// or
NetomiChat.shared.setInitialMenu(nil)
```

---

### 🧩 Send Custom Parameters

You can pass custom parameters to personalize the chat experience or pass session-specific metadata to the AI backend.

#### 🔹 To send a single key-value parameter

```swift
// Example: Indicate that the current user is a premium member
NetomiChat.shared.sendCustomParameter(name: "user_role", value: "premium_user")
```

#### 🔹 To set multiple custom parameters at once

```swift
// Example: Pass user profile info during initialization
let userAttributes: [String: String] = [
  "user_id": "12345",                // Unique ID of the user
  "user_name": "John Doe",           // Optional full name
  "membership_level": "gold",        // Tier of user (e.g., gold, silver)
  "app_version": "7.2.0"             // Current app version for debugging or targeting
]

NetomiChat.shared.setCustomParameter(userAttributes)
```

---

### 🧾 Pass Custom API Headers (Optional)

> Send custom HTTP headers with each SDK API request — useful for:
>
> - Authentication tokens
> - Versioning
> - Experiment targeting
> - Localization context

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
Avoid including any sensitive data like passwords or secrets.

---

### 🔊 Configure Audio Session (Optional)

The SDK manages audio session behavior for voice features by default. If your app owns `AVAudioSession`, configure this before launching chat.

```swift
NetomiChat.shared.configureAudioSession(
    forceSpeakerOutput: true,
    disableSessionControl: false
)
```

- `forceSpeakerOutput`: Routes audio to speaker when no Bluetooth or wired output is connected.
- `disableSessionControl`: Set to `true` when your app manages audio activation/deactivation itself.

---

### 🎨 Apply UI Customization (Optional)

Call UI customization APIs before `launch()` so overrides are applied when the chat opens.

```swift
/// 🧩 Header Configuration: App bar at the top of the chat
var header = NCWHeaderConfiguration()
header.backgroundColor = .systemBlue                     // Set header background color
header.isGradientApplied = true                          // Enable gradient effect
header.isBackPressPopupEnabled = true                    // Show confirmation popup on back
header.navigationIcon = UIImage(named: "logo")          // Optional: Add a custom logo icon
NetomiChat.shared.updateHeaderConfiguration(config: header)

/// 🧩 Footer Configuration: Input area at the bottom
var footer = NCWFooterConfiguration()
footer.backgroundColor = .white                          // Background color of input footer
footer.inputBoxTextColor = .darkGray                    // Text color for message input
footer.isFooterHidden = false                           // Show/hide the footer
footer.isNetomiBrandingEnabled = true                   // Show "Powered by Netomi" branding
NetomiChat.shared.updateFooterConfiguration(config: footer)

/// 🧩 Bot Message Bubble Styling
var botConfig = NCWBotConfiguration()
botConfig.backgroundColor = .lightGray                   // Bot message background
botConfig.textColor = .black                             // Bot message text color
botConfig.quickReplyBackgroundColor = .systemGray4       // Quick reply pill color
botConfig.isFeedbackEnabled = true                       // Enable thumbs up/down feedback
NetomiChat.shared.updateBotConfiguration(config: botConfig)


/// 🧩 User Message Bubble Styling
var userConfig = NCWUserConfiguration()
userConfig.backgroundColor = .darkGray                   // User message bubble color
userConfig.textColor = .white                            // Text color in user bubbles
userConfig.retryColor = .red                             // Retry button color (on failure)
userConfig.quickReplyBackgroundColor = .gray             // Optional quick reply pill style
NetomiChat.shared.updateUserConfiguration(config: userConfig)


/// 🧩 Chat Bubble Settings (general style)
var bubbleConfig = NCWBubbleConfiguration()
bubbleConfig.borderRadius = 16                           // Rounded corners for messages
bubbleConfig.timeStampColor = .gray                      // Timestamp text color
NetomiChat.shared.updateBubbleConfiguration(config: bubbleConfig)


/// 🧩 Entire Chat Window Background
var windowConfig = NCWChatWindowConfiguration()
windowConfig.chatWindowBackgroundColor = .white          // Background behind all chat bubbles
NetomiChat.shared.updateChatWindowConfiguration(config: windowConfig)

/// 🧩 Miscellaneous Title and Info Section Styling
var otherConfig = NCWOtherConfiguration()
otherConfig.backgroundColor = .white                     // Info section background
otherConfig.titleColor = .black                          // Title text
otherConfig.descriptionColor = .darkGray                 // Description/subtext
NetomiChat.shared.updateOtherConfiguration(config: otherConfig)

/// 🧩 Alerts Styling
var alertsConfig = NCWAlertsConfiguration()
alertsConfig.highAlert = .defaultHigh()
NetomiChat.shared.updateAlertsConfiguration(config: alertsConfig)

/// 🧩 Terms and Conditions Styling
var termsConfig = NCWTermsConfiguration()
termsConfig.backgroundColor = .white
termsConfig.titleColor = .black
NetomiChat.shared.updateTermsConfiguration(config: termsConfig)

```

---

### 🔔 Push Token Registration

#### Set Push Token (Preferred)

```swift
NetomiChat.shared.setPushToken("your-push-token")
```

#### Deprecated (Do Not Use)

```swift
NetomiChat.shared.setFCMToken("your-fcm-token")
```

> ⚠️ `setFCMToken(_:)` is deprecated. Use `setPushToken(_:)` instead.
---

### 🪟 Manage Chat UI Visibility

You can programmatically check whether the chat UI is currently visible, resume a hidden chat, or hide/destroy it.

> ℹ️ `hideChat` and `resumeChat` are synchronous APIs executed on the main thread.  

#### 🔹 Check if Chat is Visible

```swift
if NetomiChat.shared.isChatVisible() {
    print("Chat is currently visible")
}
```

#### 🔹 Resume a Previously Hidden Chat

```swift
NetomiChat.shared.resumeChat(animationConfig: NCWAnimationConfig(animationType: .fade))
```

> If there’s no hidden chat to resume, this will be a no-op.  
> The default animation is `.system` with a `0.3s` duration (falls back to fade).

#### 🔹 Hide or Destroy Chat

```swift
NetomiChat.shared.hideChat(mode: .hide, animationConfig: NCWAnimationConfig(animationType: .fade, duration: 0.25))
```

- `.destroy` → Tears down the UI so the next open starts fresh.  
- `.hide` → Keeps the UI off-screen so it can be resumed later.  
- `animationConfig` → Optional animation preset and duration.  

---

## 🔔 Event Handling

The SDK provides a way for your app to **receive event callbacks** from the SDK as well as to **send events** into it.

### Receive Events from SDK

```swift
NetomiChat.shared.getEventUpdatesFromSDK = { [weak self] event in
    guard let self else { return }

    guard let typeString = event[NCWPublicEventKeys.eventType.rawValue] as? String,
            let eventType = NCWPublicEvent(rawValue: typeString) else {
        return
    }

    let eventData = event[NCWPublicEventKeys.eventData.rawValue] as? [String: Any] ?? [:]

    switch eventType {
        
    case .chatSdkInitialised:
        print("SDK initialized", eventData)

    case .reauthorizationRequest:
        Task { @MainActor in
            print("Reauthorization requested:", eventData)

            // Example:
            // Show your app’s authentication UI
            // After success/failure, notify the SDK using sendEventToSdk(...)
        }

    case .reauthorizationResponse:
        print("Reauthorization response received")

    case .chatOpened:
        print("Chat opened")

    case .error:
        print("SDK error event:", eventData)

    default:
        break
    }
}
```

### Send Events to SDK

Use `sendEventToSdk(type:eventName:jwt:data:)` when the SDK expects a response from the host app, such as JWT reauthorization, or when you need to send a supported custom event.

#### Reauthorization Success

```swift
do {
    try NetomiChat.shared.sendEventToSdk(
        type: .reauthorizationSuccess,
        jwt: "eyJhbGciOi...",   // Required for reauthorization success
        data: ["conversation_id": "12345"]
    )
} catch {
    print("Failed: \(error)")
}
```

#### Reauthorization Failure

```swift
do {
    try NetomiChat.shared.sendEventToSdk(
        type: .reauthorizationFailure,
        data: ["reason": "user_cancelled"]
    )
} catch {
    print("Failed: \(error)")
}
```

#### Custom Event

```swift
do {
    try NetomiChat.shared.sendEventToSdk(
        type: .custom,
        eventName: "html_state_update",
        data: [
            "status": "submitted",
            "custom_attributes": [
                "formId": "feedback_form"
            ]
        ]
    )
} catch {
    print("Failed: \(error)")
}
```

- `type`: Event category sent to the SDK.
- `eventName`: Required only when `type` is `.custom`.
  - Must be non-empty.
  - Must not use reserved SDK event names such as `reauthorization_success`, `reauthorization_failure`, or `custom`.
- `jwt`: An **optional JSON Web Token**.
  - Required for `.reauthorizationSuccess`.
  - Ignored if not applicable.
- `data`: A JSON-serializable dictionary for additional payload. Defaults to `[:]`.
  - Values must be compatible with JSON serialization.

### 📚 Supported Event Types

|Event Type|Description|
|----------|-----------|
|`.reauthorizationSuccess`|Reauthorization completed successfully.|
|`.reauthorizationFailure`|Reauthorization failed.|
|`.custom`|Vendor/app-specific event. Requires `eventName`.|

---

### 🔍 Enable Logging

You can set the log level at any time during app runtime:

```swift
#if DEBUG
NetomiChat.shared.setupLogging(level: .info)
#endif
```

### 📚 Available Log Levels

|Level|Description|
|-----|-----------|
|`.none`|No logs will be printed (recommended for production).|
|`.error`|Prints only SDK-related public error logs.|
|`.info`|Prints both public informational and error logs (ideal for development).|

> **Default:** `.none`

---

## 🧪 Example App

An **example iOS app** is included under `/Example` to demonstrate SDK
integration.

### Run the Example

1. Open: `Example/NetomiSampleApp.xcworkspace`

2. In `HomeViewController.swift`, replace:

    ```swift
    NetomiChat.shared.initialize(
        botRefId: "YOUR_BOT_REF_ID",
        env: .USProd
    )
    ```

    with your `botRefId` and the appropriate `env`.

3. Build & Run on a simulator or physical device.

---

## 🛠 Support

For SDK issues or integration help:

- 📘 [Netomi Website](https://www.netomi.com)
- 📩 [support@netomi.com](mailto\:support@netomi.com)

---

## 📄 License

```text
© 2026 Netomi. All rights reserved.
The Netomi Mobile Chat SDK may include its own license terms.
Refer to Netomi's official documentation for legal details.
```
