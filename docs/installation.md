# Installation

[← Back to documentation index](../README.md)

> **What this guide covers:** how to add the SDK to your project, the supported installation methods, and the third-party dependencies managed by the SDK.
>
> **Read this when:** you are integrating the SDK for the first time, or upgrading to a new version.
>
> **Which should I choose?** Use **Swift Package Manager** for new integrations. It is the recommended long-term path. Pick **one** method per app target; do not mix both.
>
> ⚠️ **CocoaPods support is deprecated.** Netomi will publish `NetomiChatSDK` CocoaPods releases (base pod and the `/Analytics` subspec alike) only until **October 1, 2026**. **Swift Package Manager is the preferred and long-term supported integration method.** If you currently use CocoaPods, migrate before October 1, 2026 — see [Migrating from CocoaPods to Swift Package Manager](#migrating-from-cocoapods-to-swift-package-manager).

## CocoaPods sunset timeline

Two separate, unrelated dates are in play — Netomi's own deprecation, and CocoaPods.org's own infrastructure change:

| Date | What ends | Source |
| --- | --- | --- |
| **October 1, 2026** | Netomi stops publishing new `NetomiChatSDK` versions (base pod **and** `/Analytics` subspec). Already-published versions remain installable. | Netomi |
| November 1–7, 2026 | CocoaPods Trunk read-only test window — publishing to *any* pod, SDK-wide, may fail intermittently. | [CocoaPods.org](https://blog.cocoapods.org/CocoaPods-Specs-Repo/) |
| December 2, 2026 | CocoaPods Trunk becomes permanently read-only — no pod of any kind, from any publisher, can be published anymore. | [CocoaPods.org](https://blog.cocoapods.org/CocoaPods-Specs-Repo/) |

**Practical takeaway:** treat **October 1, 2026** as your deadline. It arrives before either CocoaPods.org milestone, so there is no scenario where waiting for the CocoaPods.org dates buys you extra time on `NetomiChatSDK`.

---

## Prerequisites

- iOS 16 or later
- Xcode 26+
- UIKit or SwiftUI (both supported by the SDK)
- Swift Package Manager or CocoaPods. Manual framework integration is not supported because the SDK depends on managed third-party packages.
- Your Bot Credentials from Netomi (`botRefId`, `environment`)

> **Important:** Use either Swift Package Manager or CocoaPods for a given app target, not both. Do not add Lottie or Netomi binary frameworks manually when using `NetomiChatSDK`; the package or pod manages those dependencies for you.

---

## Option 1 — Swift Package Manager (recommended)

> **Swift Package Manager is the recommended long-term installation path.**
> See the CocoaPods sunset note below.

1. Go to **Xcode > Project > Package Dependencies**
2. Add repository:

   ```text
   https://github.com/msgai/netomi-chat-ios.git
   ```

3. Select the tag or branch: `1.31.0`

4. Choose package products:

   - Add `Netomi` for the base SDK without optional analytics.
   - Add both `Netomi` and `NetomiAnalytics` to opt in to optional analytics. Mixpanel is the currently included provider.

   Mixpanel is linked only when `NetomiAnalytics` is selected.

5. Import and use the SDK:

    ```swift
    import Netomi

    // Required only when the NetomiAnalytics product is selected.
    import NetomiAnalytics
    NetomiAnalyticsSupport.enable()
    ```

---

## Option 2 — CocoaPods (deprecated, supported until October 1, 2026)

> ⚠️ Netomi is deprecating CocoaPods support for both the base pod and the `Analytics` subspec below. No new `NetomiChatSDK` podspec versions will be published after **October 1, 2026** — see the [full sunset timeline](#cocoapods-sunset-timeline). New integrations should use [Swift Package Manager](#option-1--swift-package-manager-recommended); existing CocoaPods users should plan to [migrate before then](#migrating-from-cocoapods-to-swift-package-manager).

1. Add this to your `Podfile`:

   ```ruby
   # Base SDK without optional analytics
   pod 'NetomiChatSDK', '1.31.0'

   # Optional analytics support. Mixpanel is the current provider.
   # pod 'NetomiChatSDK/Analytics', '1.31.0'
   ```

2. Run:

   ```bash
   pod install
   ```

3. Open `.xcworkspace` in Xcode.

4. ✅ **Required Third-Party Dependencies**

   Mixpanel is installed only when you select the `Analytics` subspec.

5. Import and use the SDK:

    ```swift
    import Netomi

    // Required only when using NetomiChatSDK/Analytics.
    NetomiAnalyticsSupport.enable()
    ```

> **Note:** CocoaPods.org is also winding down Trunk publishing SDK-wide, on a different schedule than Netomi's own sunset — see the [full timeline](#cocoapods-sunset-timeline) above.

---

## Migrating from CocoaPods to Swift Package Manager

CocoaPods support ends **October 1, 2026**. Move existing `NetomiChatSDK` CocoaPods integrations to Swift Package Manager before then:

1. **Note your current pods.** Check your `Podfile` for `pod 'NetomiChatSDK'` and, if present, `pod 'NetomiChatSDK/Analytics'` — you'll add the equivalent SPM products in step 4.
2. **Remove the CocoaPods integration.**

   ```bash
   pod deintegrate
   ```

   Then delete the `pod 'NetomiChatSDK'` (and `/Analytics`) lines from your `Podfile`, or remove the `Podfile` entirely if `NetomiChatSDK` was its only dependency.

3. **Close `.xcworkspace` and open the underlying `.xcodeproj`** in Xcode.
4. **Add the SPM package** by following [Option 1 — Swift Package Manager](#option-1--swift-package-manager-recommended) above:
   - Add the `Netomi` product (equivalent to `pod 'NetomiChatSDK'`).
   - Also add `NetomiAnalytics` if you previously used `pod 'NetomiChatSDK/Analytics'`.
   - Select the same version/tag you were pinned to in your `Podfile`.
5. **Remove any manually vendored copies** of AWS IoT Core, Lottie, or Mixpanel — SPM manages the same dependencies CocoaPods did. Leaving both in place causes duplicate-symbol build errors.
6. **Build and run.** Your `import Netomi` / `import NetomiAnalytics` statements and `NetomiAnalyticsSupport.enable()` call are unchanged — no API changes are required to migrate.
7. **Delete `Podfile.lock`** and any leftover `Pods/` directory once the build succeeds on SPM.

> Hitting an issue during migration? See **[Troubleshooting & FAQ](troubleshooting.md)**, or contact [support@netomi.com](mailto:support@netomi.com).

---

## Managed Dependency Versions

`NetomiChatSDK` manages these third-party dependencies:

| Dependency | Version Range |
| --- | --- |
| Mixpanel Swift (optional) | `6.4.0..<7.0.0` |

Do not add separate versions of these dependencies unless `Netomi` support asks you to do so. `Mixpanel` is installed only when the optional analytics product or subspec is selected.

> AWS IoT Device SDK for Swift and Lottie are also used internally, but are statically embedded inside the SDK's core binary with their symbols hidden — they are never separate dependencies you add or manage.

---

### ➡️ Next step

Installed the SDK? Continue to **[Usage](usage.md)** to initialize and launch
the chat.

> Hitting a build or install error? See **[Troubleshooting & FAQ](troubleshooting.md)**.
