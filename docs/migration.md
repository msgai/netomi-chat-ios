# Migration Guide

Removed APIs and how to update your code. Each entry shows what to change; the replacement APIs are already available in earlier releases, so you can migrate **before** upgrading.

## Removed deprecated APIs

The following APIs were deprecated and have now been removed. If your app still uses one, the build fails after upgrading. Replace it as shown below.

| Removed | Use instead |
|---|---|
| `NetomiChat.shared.setFCMToken(_:)` | `NetomiChat.shared.setPushToken(_:)` |
| `typingMessageCornerRadius` property on a `NCWFooterConfiguration` instance | `inputBoxCornerRadius` on the same instance |
| `sendBackgroundColor` property on a `NCWFooterConfiguration` instance | `sendButtonBackgroundColor` on the same instance |

### `setFCMToken(_:)` → `setPushToken(_:)`

`setPushToken(_:)` accepts both APNs and FCM tokens, so the call is a direct rename.

```swift
// Before
NetomiChat.shared.setFCMToken(fcmToken)

// After
NetomiChat.shared.setPushToken(fcmToken)
```

See [Push Notifications](push-notifications.md) for full setup.

### `NCWFooterConfiguration` properties

Both are properties you set on a `NCWFooterConfiguration` instance before passing it to `updateFooterConfiguration(config:)`. Just rename the property; you still assign a `CGFloat` or `UIColor` as before.

```swift
// Before
var footer = NCWFooterConfiguration()
footer.typingMessageCornerRadius = 12
footer.sendBackgroundColor = .systemBlue
NetomiChat.shared.updateFooterConfiguration(config: footer)

// After
var footer = NCWFooterConfiguration()
footer.inputBoxCornerRadius = 12
footer.sendButtonBackgroundColor = .systemBlue
NetomiChat.shared.updateFooterConfiguration(config: footer)
```

See [UI Theming](ui-theming.md) for the footer options.

### ➡️ Related

- Push token setup → **[Push Notifications](push-notifications.md)**
- Styling options → **[UI Theming](ui-theming.md)**
- Something not working → **[Troubleshooting & FAQ](troubleshooting.md)**
