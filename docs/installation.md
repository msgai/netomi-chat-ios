# Installation

[← Back to documentation index](../README.md)

> **What this guide covers:** how to add the SDK to your project, the supported installation methods, and the third-party dependencies managed by the SDK.
>
> **Read this when:** you are integrating the SDK for the first time, or upgrading to a new version.
>
> **Which should I choose?** Use **Swift Package Manager** for new integrations. It is the recommended long-term path. Pick **one** method per app target; do not mix both.

---

## Prerequisites

- iOS 16 or later
- Xcode 26+
- UIKit or SwiftUI (both supported by the SDK)
- Swift Package Manager or CocoaPods. Manual framework integration is not supported because the SDK depends on managed third-party packages.
- Your Bot Credentials from Netomi (`botRefId`, `environment`)

> **Important:** Use either Swift Package Manager or CocoaPods for a given app target, not both. Do not add AWS, Microsoft Speech, Datadog, Lottie, or Netomi binary frameworks manually when using `NetomiChatSDK`; the package or pod manages those dependencies for you.

---

## Option 1 — Swift Package Manager (recommended)

> **Swift Package Manager is the recommended long-term installation path.**
> See the CocoaPods sunset note below.

1. Go to **Xcode > Project > Package Dependencies**
2. Add repository:

   ```text
   https://github.com/msgai/netomi-chat-ios.git
   ```

3. Select the tag or branch: `1.27.0`

4. Choose package products:

   - Add `Netomi` for the base SDK without optional analytics.
   - Add both `Netomi` and `NetomiAnalytics` to opt in to optional analytics. Mixpanel is the currently included provider.

   The `Netomi` product links AWS IoT Core, Microsoft Cognitive Services Speech SDK, Datadog, and Lottie automatically. Mixpanel is linked only when `NetomiAnalytics` is selected.

5. Import and use the SDK:

    ```swift
    import Netomi

    // Required only when the NetomiAnalytics product is selected.
    import NetomiAnalytics
    NetomiAnalyticsSupport.enable()
    ```

---

## Option 2 — CocoaPods

1. Add this to your `Podfile`:

   ```ruby
   # Base SDK without optional analytics
   pod 'NetomiChatSDK', '1.27.0'

   # Optional analytics support. Mixpanel is the current provider.
   # pod 'NetomiChatSDK/Analytics', '1.27.0'
   ```

2. Run:

   ```bash
   pod install
   ```

3. Open `.xcworkspace` in Xcode.

4. ✅ **Required Third-Party Dependencies**

   CocoaPods installs AWS IoT Core, Microsoft Cognitive Services Speech SDK, Datadog, and Lottie automatically through `NetomiChatSDK`. Mixpanel is installed only when you select the `Analytics` subspec.

5. Import and use the SDK:

    ```swift
    import Netomi

    // Required only when using NetomiChatSDK/Analytics.
    NetomiAnalyticsSupport.enable()
    ```

> **Note:** CocoaPods has announced a read-only test window from **November 1-7, 2026**, followed by the permanent Trunk read-only switch on **December 2, 2026**.
>
> - Existing published versions of `NetomiChatSDK` should remain installable.
> - Publishing automation may fail during the November 1-7, 2026 test window.
> - New `NetomiChatSDK` podspec versions will no longer be publishable to Trunk
>   after December 2, 2026.
> - For new integrations, **Swift Package Manager is the recommended long-term
>   installation path**.
>
> Reference: <https://blog.cocoapods.org/CocoaPods-Specs-Repo/>

---

## Managed Dependency Versions

`NetomiChatSDK` manages these third-party dependencies:

| Dependency | Version Range |
| --- | --- |
| AWS IoT Core | `2.41.0..<2.42.0` |
| Microsoft Cognitive Services Speech SDK | `1.49.1` |
| Datadog Core / Logs | `3.11.0..<3.12.0` |
| Lottie | `4.6.0..<4.7.0` |
| Mixpanel Swift (optional) | `6.4.0..<7.0.0` |

Do not add separate versions of these dependencies unless `Netomi` support asks you to do so. `Lottie` is part of the core SDK. `Mixpanel` is installed only when the optional analytics product or subspec is selected.

---

### ➡️ Next step

Installed the SDK? Continue to **[Usage](usage.md)** to initialize and launch
the chat.

> Hitting a build or install error? See **[Troubleshooting & FAQ](troubleshooting.md)**.
