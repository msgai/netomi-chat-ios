# Netomi Mobile Chat SDK (iOS)

## Overview

The Netomi Mobile Chat SDK makes it easy to embed conversational AI into your iOS application. It supports:
- Rich media responses
- Forms and file attachments
- Live agent handoff
- Customizable look and feel

This sample app demonstrates the core integration steps and includes code examples for customizing various aspects of the chat UI.

## Prerequisites
- iOS 15 or later
- Xcode 13 or later
- UIKit or SwiftUI (both supported by the SDK)
- CocoaPods or Swift Package Manager installed/configured
- Bot Credentials (i.e., botRefId and environment `env`) from Netomi

## Setup & Installation

#### CocoaPods
1. Navigate to the project folder containing the `Podfile`.
2. Add the SDK in the `Podfile`:

```ruby
pod 'NetomiChatSDK', '1.0.0'
```

3. Install:

```bash
pod install
```

4. Open the generated `.xcworkspace` file in Xcode.

#### Swift Package Manager (SPM)
1. Open your Xcode project and go to `Project > Package Dependencies`.
2. Add a new package using:

```
https://github.com/msgai/netomi-chat-ios.git
https://github.com/aws-amplify/aws-sdk-ios-spm.git with AWSCore & AWSIoT packages.
```

3. Select the main branch or a version tag, then finish adding.
4. Build your project to ensure the dependency is resolved.

## Build & Run
1. In Xcode, select a simulator or connected device running iOS 15+.
2. Build (`⌘+B`) and Run (`⌘+R`).
3. The sample app's main screen will display a button or entry to Launch Chat.

## Sample Code Walkthrough

### Initialization

In the sample’s `AppDelegate` or `SceneDelegate` (or wherever you want to initialize the SDK):

```swift
NetomiChat.shared.initialize(botRefId: "YOUR_BOT_REF_ID", environment: .USProd)
```

- `botRefId`: The unique identifier for your AI Agent.
- `environment`: Use `.USProd`, `.SGProd`, `.EUProd`, `.QA`, `.QAInternal`, or `.Development` as provided by Netomi.

### Launching the Chat

In a view controller or SwiftUI view:

```swift
NetomiChat.shared.launch(jwt: nil) { errorData in
    // Handle any errors, e.g., present an alert
}
```

- `jwt` (optional): Include if you have an authenticated user token.
- The optional error callback handles initialization or network errors.

### Sending Custom Parameters

You can pass additional user-specific data (e.g., department, user IDs):

```swift
NetomiChat.shared.sendCustomParameter(name: "department", value: "marketing")
```

This helps personalize conversations on the AI Agent side.

### Customization Examples

#### Header, Footer, and Bubble Styles

In `ViewController` or wherever you configure the chat:

```swift
// Customizing the chat header
var header = NCWHeaderConfiguration()
header.backgroundColor = .green
header.isGradientApplied = false
NetomiChat.shared.updateHeaderConfiguration(config: header)

// Customizing the chat footer
var footer = NCWFooterConfiguration()
footer.backgroundColor = .green
footer.isFooterHidden = false
NetomiChat.shared.updateFooterConfiguration(config: footer)
```

You can modify colors, gradients, branding text, icons, and more.

## Pass FCM Token

If your sample demonstrates using Firebase Cloud Messaging:

```swift
NetomiChat.shared.setFCMToken("YOUR_FCM_TOKEN_HERE")
```

Ensure Firebase is properly set up in this sample project for push notifications.

## License & Legal

© 2025 Netomi. All rights reserved. This sample app is for demonstration purposes only. The Netomi Mobile Chat SDK may include its own license terms. Review the LICENSE file in this repository (if available) and refer to official Netomi documentation for detailed legal information.

## Support

For questions, issues, or feature requests regarding this sample or the Netomi Mobile Chat SDK:
- Visit [Netomi.com](http://www.netomi.com) for official support.
- Contact your Netomi representative directly.

Happy coding!
