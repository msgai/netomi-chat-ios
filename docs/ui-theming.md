# UI Theming

[← Back to documentation index](../README.md)

> **What this guide covers:** how to override the chat's visual styling in code: colors, the header, footer, message bubbles, other UI elements, and dark mode.
>
> **Read this when:** the Netomi Dashboard styling is not enough and you need code-level control.
>
> 🔹 **Prefer the Dashboard first.** Most visual styling can be configured via the Netomi Dashboard without any code. Use the APIs below only when you need to override styling locally in the app.

## 🌗 Light & Dark Theme

The Dashboard can configure two independent themes:

```json
{
  "lightTheme": { /* same shape as today */ },
  "darkTheme": { /* same shape — every option below is available for dark mode too */ },
  "themeMode": "light"
}
```

`themeMode` decides which theme is active by default:

| Value | Behavior |
| --- | --- |
| `light` | Always use `lightTheme`. |
| `dark` | Always use `darkTheme`. |
| `auto` | Follow the device's system appearance (Light/Dark). |

**Backward compatibility:** if `themeMode` is omitted (existing integrations that only configure `lightTheme`), the SDK defaults to `light` — behavior is unchanged.

### Overriding the theme mode at runtime

Use `overrideThemeMode(_:)` to force a theme mode from your app, regardless of what the Dashboard configured. Unlike the configuration APIs below, this applies **immediately** — it does not require calling before `launch()` and does not require reinitializing the SDK. In `.auto`, the SDK keeps tracking system appearance changes live.

```swift
// Force dark mode, e.g. to match your app's own theme toggle
NetomiChat.shared.overrideThemeMode(.dark)

// Follow the system appearance again
NetomiChat.shared.overrideThemeMode(.auto)

// Clear the override and fall back to the Dashboard-configured themeMode
NetomiChat.shared.overrideThemeMode(nil)

// Read the mode currently in effect (override if set, otherwise the configured value)
let mode = NetomiChat.shared.currentThemeMode
```

### `.auto` requires your app to support both appearances

`.light` and `.dark` always work, no matter how your app is configured — they force a concrete style on the chat regardless of anything else.

`.auto` is different: it does not poll the device directly. It inherits whatever appearance your app process is currently allowed to display. If your app's **Info.plist** locks the whole app to one style:

```xml
<key>UIUserInterfaceStyle</key>
<string>Light</string>  <!-- or Dark -->
```

iOS prevents that app — every window in it, including the chat's — from ever seeing the other style. The device's actual Dark Mode setting never reaches your app, so `.auto` will always resolve to whichever style is locked.

| Your app's Info.plist | `theme(.light)` / `overrideThemeMode(.light)` | `theme(.dark)` / `overrideThemeMode(.dark)` | `.auto` |
| --- | --- | --- | --- |
| `UIUserInterfaceStyle: Light` | ✅ works | ✅ works | always resolves to light |
| `UIUserInterfaceStyle: Dark` | ✅ works | ✅ works | always resolves to dark |
| No key (or `Automatic`) | ✅ works | ✅ works | ✅ tracks the device live |

If your app only ever supports a single appearance, that's not an issue by itself — just use the matching explicit `themeMode` (or `overrideThemeMode`) instead of `.auto`. `.auto` specifically requires the host app to **not** lock `UIUserInterfaceStyle`, since it has nothing else to inherit from.

### Scoping code-level overrides to light or dark

There are only **two** override buckets, no matter how you call these APIs: a **default** bucket and a **dark-only** bucket. Where each call writes to, and when each bucket is used, is fixed:

| Call | Writes to | Used when |
| --- | --- | --- |
| `NetomiChat.shared.updateBotConfiguration(config:)` (unscoped) | **default** bucket | light mode — and dark mode too, *unless* you've also set a dark-specific override (see below) |
| `NetomiChat.shared.theme(.light).updateBotConfiguration(config:)` | **default** bucket (identical to the unscoped call above) | same as above |
| `NetomiChat.shared.theme(.auto).updateBotConfiguration(config:)` | **default** bucket (identical to the unscoped call above) | same as above — `.auto` is a mode *selector*, not a separate bucket |
| `NetomiChat.shared.theme(.dark).updateBotConfiguration(config:)` | **dark-only** bucket | dark mode only — takes priority over the default bucket for whichever properties it sets |

In other words: `theme(.light)` and `theme(.auto)` are just spellings of the same unscoped call — they all land in the one default bucket. The **only** call that behaves differently is `theme(.dark)`.

If you never call `theme(.dark)`, dark mode silently reuses your default overrides — nothing changes for existing integrations. Call `theme(.dark)` only for the specific properties that should look different in dark mode; everything else still falls back to the default bucket.

```swift
// Default bucket — used in light mode, and as the dark-mode fallback
NetomiChat.shared.updateBotConfiguration(config: botConfig)

// Dark-only bucket — wins over the default bucket, but only while the chat is in dark mode
var darkBotConfig = NCWBotConfiguration()
darkBotConfig.backgroundColor = .black
darkBotConfig.textColor = .white
NetomiChat.shared.theme(.dark).updateBotConfiguration(config: darkBotConfig)
```

## When to apply theming

Call all UI customization APIs **before `launch()`** so the overrides are applied when the chat opens. Changes made after the chat is visible are not guaranteed to take effect on the current session.

> Each configuration object below is **independent**. Apply only the ones you need. You do not have to set every property; unspecified properties keep their default values.
>
> ⚠️ **`theme(.light)` and `theme(.auto)` are not separate buckets — they're the same call as the unscoped method shown below.** `NetomiChat.shared.updateTermsConfiguration(config:)`, `NetomiChat.shared.theme(.light).updateTermsConfiguration(config:)`, and `NetomiChat.shared.theme(.auto).updateTermsConfiguration(config:)` all write to the one **default** bucket — calling more than one of them just overwrites the same values again. The **only** call that writes somewhere different is `theme(.dark)`. Each section below shows the unscoped form + `theme(.dark)` for brevity; swap in `theme(.light)`/`theme(.auto)` if you prefer to be explicit, but don't call both the unscoped form *and* `theme(.light)` expecting two different results. See [Scoping code-level overrides to light or dark](#scoping-code-level-overrides-to-light-or-dark) above.

---

## 🧩 Header

The app bar at the top of the chat.

**Default** — used in light mode, and as the dark-mode fallback for anything not set below:

```swift
var header = NCWHeaderConfiguration()
header.backgroundColor = .systemBlue           // Header background color
header.isGradientApplied = true                // Enable gradient effect
header.isBackPressPopupEnabled = true          // Confirm on back
header.navigationIcon = UIImage(named: "logo") // Optional: custom logo icon
NetomiChat.shared.updateHeaderConfiguration(config: header)
```

**Dark mode override** — optional, wins over the default above only while the chat is in dark mode:

```swift
var darkHeader = NCWHeaderConfiguration()
darkHeader.backgroundColor = .black
NetomiChat.shared.theme(.dark).updateHeaderConfiguration(config: darkHeader)
```

---

## 🧩 Footer

The message input area at the bottom.

```swift
var footer = NCWFooterConfiguration()
footer.backgroundColor = .white            // Input footer background color
footer.inputBoxTextColor = .darkGray       // Message input text color
footer.isFooterHidden = false              // Show/hide the footer
footer.isNetomiBrandingEnabled = true      // Show "Powered by Netomi" branding
NetomiChat.shared.updateFooterConfiguration(config: footer)
```

**Dark mode override**:

```swift
var darkFooter = NCWFooterConfiguration()
darkFooter.backgroundColor = .black
darkFooter.inputBoxTextColor = .white
NetomiChat.shared.theme(.dark).updateFooterConfiguration(config: darkFooter)
```

---

## 🧩 Bot Message Bubbles

Styling for bot messages and their quick replies.

```swift
var botConfig = NCWBotConfiguration()
botConfig.backgroundColor = .lightGray             // Bot message background
botConfig.textColor = .black                       // Bot message text color
botConfig.quickReplyBackgroundColor = .systemGray4 // Quick reply pill color
botConfig.isFeedbackEnabled = true                 // Enable feedback
NetomiChat.shared.updateBotConfiguration(config: botConfig)
```

**Dark mode override**:

```swift
var darkBotConfig = NCWBotConfiguration()
darkBotConfig.backgroundColor = .darkGray
darkBotConfig.textColor = .white
NetomiChat.shared.theme(.dark).updateBotConfiguration(config: darkBotConfig)
```

---

## 🧩 User Message Bubbles

Styling for messages sent by the user.

```swift
var userConfig = NCWUserConfiguration()
userConfig.backgroundColor = .darkGray         // User message bubble color
userConfig.textColor = .white                  // User message text color
userConfig.retryColor = .red                   // Failed-message retry color
userConfig.quickReplyBackgroundColor = .gray   // Quick reply pill style
NetomiChat.shared.updateUserConfiguration(config: userConfig)
```

**Dark mode override**:

```swift
var darkUserConfig = NCWUserConfiguration()
darkUserConfig.backgroundColor = .systemBlue
NetomiChat.shared.theme(.dark).updateUserConfiguration(config: darkUserConfig)
```

---

## 🧩 Bubble (General Style)

Shared bubble styling applied to all messages.

```swift
var bubbleConfig = NCWBubbleConfiguration()
bubbleConfig.borderRadius = 16        // Rounded corners for messages
bubbleConfig.timeStampColor = .gray   // Timestamp text color
NetomiChat.shared.updateBubbleConfiguration(config: bubbleConfig)
```

**Dark mode override** — `borderRadius` isn't set here, so it still falls back to the default above:

```swift
var darkBubbleConfig = NCWBubbleConfiguration()
darkBubbleConfig.timeStampColor = .lightGray
NetomiChat.shared.theme(.dark).updateBubbleConfiguration(config: darkBubbleConfig)
```

---

## 🧩 Chat Window Background

The background behind all chat bubbles.

```swift
var windowConfig = NCWChatWindowConfiguration()
windowConfig.chatWindowBackgroundColor = .white
NetomiChat.shared.updateChatWindowConfiguration(config: windowConfig)
```

**Dark mode override**:

```swift
var darkWindowConfig = NCWChatWindowConfiguration()
darkWindowConfig.chatWindowBackgroundColor = .black
NetomiChat.shared.theme(.dark).updateChatWindowConfiguration(config: darkWindowConfig)
```

---

## 🧩 Titles & Info Section

Styling for titles and informational/subtext sections.

```swift
var otherConfig = NCWOtherConfiguration()
otherConfig.backgroundColor = .white     // Info section background
otherConfig.titleColor = .black          // Title text color
otherConfig.descriptionColor = .darkGray // Description/subtext color
NetomiChat.shared.updateOtherConfiguration(config: otherConfig)
```

**Dark mode override**:

```swift
var darkOtherConfig = NCWOtherConfiguration()
darkOtherConfig.backgroundColor = .black
darkOtherConfig.titleColor = .white
darkOtherConfig.descriptionColor = .lightGray
NetomiChat.shared.theme(.dark).updateOtherConfiguration(config: darkOtherConfig)
```

---

## 🧩 Alerts

Styling for alert banners shown in the chat.

```swift
var alertsConfig = NCWAlertsConfiguration()
alertsConfig.highAlert = .defaultHigh()
NetomiChat.shared.updateAlertsConfiguration(config: alertsConfig)
```

**Dark mode override**:

```swift
var darkAlertsConfig = NCWAlertsConfiguration()
darkAlertsConfig.highAlert = .defaultHigh() // customize colors for dark mode as needed
NetomiChat.shared.theme(.dark).updateAlertsConfiguration(config: darkAlertsConfig)
```

---

## 🧩 Terms & Conditions

Styling for the terms and conditions screen.

```swift
var termsConfig = NCWTermsConfiguration()
termsConfig.backgroundColor = .white
termsConfig.titleColor = .black
NetomiChat.shared.updateTermsConfiguration(config: termsConfig)
```

**Dark mode override**:

```swift
var darkTermsConfig = NCWTermsConfiguration()
darkTermsConfig.backgroundColor = .black
darkTermsConfig.titleColor = .white
NetomiChat.shared.theme(.dark).updateTermsConfiguration(config: darkTermsConfig)
```

---

## ✅ Apply, Then Launch

After setting the configurations you need, launch the chat so the styling is applied:

```swift
// Apply styling before launching so it takes effect when the chat opens.
NetomiChat.shared.launch()
```

---

### ➡️ Related

- Open the chat after styling → **[Usage](usage.md)**
- Customize the initial menu shown to users → **[Advanced](advanced.md)**
- Theming not taking effect? → **[Troubleshooting & FAQ](troubleshooting.md)**
