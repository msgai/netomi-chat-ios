# UI Theming

[← Back to documentation index](../README.md)

> **What this guide covers:** how to override the chat's visual styling in code: colors, the header, footer, message bubbles, and other UI elements.
>
> **Read this when:** the Netomi Dashboard styling is not enough and you need code-level control.
>
> 🔹 **Prefer the Dashboard first.** Most visual styling can be configured via the Netomi Dashboard without any code. Use the APIs below only when you need to override styling locally in the app.

## When to apply theming

Call all UI customization APIs **before `launch()`** so the overrides are applied when the chat opens. Changes made after the chat is visible are not guaranteed to take effect on the current session.

> Each configuration object below is **independent**. Apply only the ones you need. You do not have to set every property; unspecified properties keep their default values.

---

## 🧩 Header

The app bar at the top of the chat.

```swift
var header = NCWHeaderConfiguration()
header.backgroundColor = .systemBlue           // Header background color
header.isGradientApplied = true                // Enable gradient effect
header.isBackPressPopupEnabled = true          // Confirm on back
header.navigationIcon = UIImage(named: "logo") // Optional: custom logo icon
NetomiChat.shared.updateHeaderConfiguration(config: header)
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

---

## 🧩 Bubble (General Style)

Shared bubble styling applied to all messages.

```swift
var bubbleConfig = NCWBubbleConfiguration()
bubbleConfig.borderRadius = 16        // Rounded corners for messages
bubbleConfig.timeStampColor = .gray   // Timestamp text color
NetomiChat.shared.updateBubbleConfiguration(config: bubbleConfig)
```

---

## 🧩 Chat Window Background

The background behind all chat bubbles.

```swift
var windowConfig = NCWChatWindowConfiguration()
windowConfig.chatWindowBackgroundColor = .white
NetomiChat.shared.updateChatWindowConfiguration(config: windowConfig)
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

---

## 🧩 Alerts

Styling for alert banners shown in the chat.

```swift
var alertsConfig = NCWAlertsConfiguration()
alertsConfig.highAlert = .defaultHigh()
NetomiChat.shared.updateAlertsConfiguration(config: alertsConfig)
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
