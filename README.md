# Netomi Mobile Chat SDK (iOS)

## Overview

The **Netomi iOS Chat SDK** adds a fully managed AI chat experience to your
app. It supports:

- 💬 Rich media responses, file attachments, and forms
- 🧑‍💼 Live agent handoff
- 🔔 Push notifications (Firebase / APNs)
- 🎨 Flexible UI styling (via the Netomi Dashboard or in code)
- 🔐 Optional JWT-authenticated sessions
- 🎙️ Voice input/output

---

## 📚 Documentation

### 📦 [Installation](docs/installation.md)

Prerequisites, Swift Package Manager, CocoaPods, and managed dependencies.
**Read this when** you are adding the SDK to a project for the first time.

### 🚀 [Usage](docs/usage.md)

Initialize, launch, hide, resume, and reset the chat.
**Read this when** you need the core chat lifecycle.

### 🎨 [UI Theming](docs/ui-theming.md)

Customize colors, headers, footers, message bubbles, and other visual styling in code.
**Read this when** the Netomi Dashboard styling is not enough.

### 🔔 [Push Notifications](docs/push-notifications.md)

Register device push tokens, handle token refresh, and migrate from the deprecated FCM API.
**Read this when** chat replies should arrive as push notifications.

### 🔐 [Events & Authentication](docs/events-and-auth.md)

Use JWT auth, receive SDK events, send events back, and handle reauthorization.
**Read this when** your bot uses authenticated sessions or you need event callbacks.

### ⚙️ [Advanced](docs/advanced.md)

Tracking consent, initial menus, custom parameters, custom API headers, audio session, and logging.
**Read this when** you need finer control beyond the basic flow.

### 🔐 [Security & Privacy](docs/security-and-privacy.md)

Tracking consent, the bundled privacy manifest, and guidance for keeping secrets and PII out of the SDK.
**Read this when** you are preparing an App Store submission or a privacy review.

### 🛠️ [Troubleshooting & FAQ](docs/troubleshooting.md)

Common issues, debugging guidance, and frequently asked questions.
**Read this when** something isn't working or you want a quick answer.

---

## ⚡ Quick Start

The three steps below get a basic chat running. See [Installation](docs/installation.md) and [Usage](docs/usage.md) guides for full details and options.

### 1. Install

Add the package with **Swift Package Manager** (recommended) using tag
`1.27.0`:

```text
https://github.com/msgai/netomi-chat-ios.git
```

> CocoaPods is also supported. See [Installation](docs/installation.md) for both
> options and the recommended long-term path.

### 2. Initialize (once, at app launch)

```swift
import Netomi

NetomiChat.shared.initialize(
    botRefId: "YOUR_BOT_REF_ID",
    env: .USProd
)
```

### 3. Launch the chat

```swift
NetomiChat.shared.launch()
```

For prefilled queries, custom animations, async launch confirmation,
hiding/resuming, and more, continue to the [Usage](docs/usage.md) guide.

---

## ✅ Prerequisites (at a glance)

- iOS 16 or later
- Xcode 26+
- UIKit or SwiftUI (both supported)
- Swift Package Manager or CocoaPods.
  Manual framework integration is **not** supported.
- Your Netomi bot credentials (`botRefId`, `environment`)

Full details, including managed dependency versions, are in [Installation](docs/installation.md).

---

## 🧪 Example App

An example iOS app is included in `/Example` to demonstrate SDK integration.

1. Open `Example/NetomiSampleApp.xcworkspace`.
2. In `HomeViewController.swift`, replace `YOUR_BOT_REF_ID` and `env` with your
   own values.
3. Build & run on a simulator or device.

---

## 🛠 Support

For SDK issues or integration help:

- 📘 [Netomi Website](https://www.netomi.com)
- 📩 [support@netomi.com](mailto:support@netomi.com)

---

## 📄 License

```text
© 2026 Netomi. All rights reserved.
The Netomi Mobile Chat SDK may include its own license terms.
Refer to Netomi's official documentation for legal details.
```
