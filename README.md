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
- Xcode 13+
- UIKit or SwiftUI (both supported by the SDK)
- CocoaPods or Swift Package Manager
- Your Bot Credentials from Netomi (`botRefId`, `env`)

---

## Installation

### 1️⃣ CocoaPods

1. Add this to your `Podfile`:

   ```ruby
   pod 'NetomiChatSDK', '1.6.0'
   ```

2. Run:

   ```bash
   pod install
   ```

3. Open `.xcworkspace` in Xcode.

4. Import and Use

    ```swift
    import Netomi 
    ```

---

### 2️⃣ Swift Package Manager (SPM)

1. Go to **Xcode > Project > Package Dependencies**
2. Add:

   ```text
   https://github.com/msgai/netomi-chat-ios.git
   ```

3. Select tag or branch: `1.6.0`

4. ✅ **Required Third-Party Dependencies** (must be added manually):

   - **AWS IoT Core**\
     Add via SPM:

     ```text
     https://github.com/aws-amplify/aws-sdk-ios-spm.git
     ```

     Select:

      - `AWSIoT`

   - **Microsoft Cognitive Services Speech SDK**

     > ⚠️ *Not available via SPM. Must be added manually.*

     **Option 1 – CocoaPods (Recommended):**

     ```ruby
     pod 'MicrosoftCognitiveServicesSpeech-iOS', '~> 1.44.0'
     ```

     **Option 2 – Manual Binary Download:**

     - Requires **iOS 15.0 or later**
     - Download:

       ```text
       https://aka.ms/csspeech/iosbinary
       ```

     - Download the binary and extract its contents.
     - In your Xcode project, add a reference to the extracted `MicrosoftCognitiveServicesSpeech.xcframework` folder and its contents.

5. Import and Use

    ```swift
    import Netomi 
    ```

---

### 3️⃣ Manual Integration (No CocoaPods / No SPM)

If you prefer to integrate manually without a dependency manager:

1. Download SDK

   - Get the latest build: [Download]({{URL}})

   - Extract to reveal `Netomi.xcframework`.

2. Add to Xcode

    - Open your Xcode project.
    - Drag `Netomi.xcframework` into the **Project Navigator** (preferably inside a `Frameworks` group).
    - In the dialog:
      - Check **Copy items if needed**.
      - Add to your app target.

3. Embed & Sign

    - Go to **Target → General → Frameworks, Libraries, and Embedded Content**.
    - Set `Netomi.xcframework` to **Embed & Sign**.

4. Add Required Dependencies

    - **AWS IoT Core** (via SPM):

      ```text
      https://github.com/aws-amplify/aws-sdk-ios-spm.git
      ```

      Select:
  
        - `AWSIoT`

    - **Microsoft Cognitive Services Speech SDK**:  
      Add via CocoaPods or manual binary as described above.

5. Import and Use

    ```swift
    import Netomi
    ```

---

## Quick Start

### ✅ Initialize SDK

```swift
NetomiChat.shared.initialize(
    botRefId: "YOUR_BOT_REF_ID",
    environment: .USProd
)
```

> Replace `YOUR_BOT_REF_ID` and choose the environment: `.USProd`, `.SGProd`, `.EUProd`, `.QA`, `.QAInternal`, `.Development`
>
> 🔹 Most visual styling can be configured via the Netomi Dashboard.  
>
> 🔹 If you'd like to customize it locally in code, see [Apply UI Customization](#-apply-ui-customization-optional)

---

### 🚀 Launch Chat

```swift
NetomiChat.shared.launch(jwt: nil) { error in
    // Handle launch error if any
}
```

Or with a search query:

```swift
NetomiChat.shared.launchWithQuery("search here", jwt: nil) { error in
    // Optional error handling
}
```

---

### 🔐 Pass JWT Token (optional)

```swift
let jwt = "your-jwt-token"
NetomiChat.shared.launch(jwt: jwt)
```

---

### 🧩 Clear Current Chat Session Manually

```swift
NetomiChat.shared.clearChatSession()
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

### 🎨 Apply UI Customization (Optional)

```swift
/// 🧩 Header Configuration: App bar at the top of the chat
var header = NCWHeaderConfiguration()
header.backgroundColor = .systemBlue                     // Set header background color
header.isGradientApplied = true                          // Enable gradient effect
header.isBackPressPopupEnabed = true                    // Show confirmation popup on back
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

```

---

### 🔔 Set Push Token

```swift
NetomiChat.shared.setPushToken("your-push-token")
```

> ⚠️ Deprecated: `setFCMToken(_:)` is deprecated. Use `setPushToken(_:)` instead.

---

### 🔍 Enable Logging

You can set the log level at any time during app runtime:

```swift
#if DEBUG
NetomiChat.shared.setLogVisibility(level: .info)
##endif
```

### 📚 Available Log Levels

| Level      | Description                                                                 |
|------------|-----------------------------------------------------------------------------|
| `.none`    |  No logs will be printed (recommended for production).                   |
| `.error`   | Prints only SDK-related public error logs.                              |
| `.info`    | Prints both public informational and error logs (ideal for development). |

> **Default:** `.none`

---

## 🛠 Support

For SDK issues or integration help:

- 📘 [Netomi Website](https://www.netomi.com)
- 📩 [support@netomi.com](mailto\:support@netomi.com)

---

## 📄 License

```text
© 2025 Netomi. All rights reserved.
The Netomi Mobile Chat SDK may include its own license terms.
Refer to Netomi's official documentation for legal details.
```
