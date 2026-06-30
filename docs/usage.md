# Usage

[← Back to documentation index](../README.md)

> **What this guide covers:** the core chat lifecycle: initializing the SDK, launching the chat, managing visibility, and clearing a session.
>
> **Read this when:** you want to open, hide, resume, or reset the chat. This is the main guide for day-to-day integration.
>
> 🧭 **Typical flow:** call `initialize(...)` once at app startup, then call `launch()` when the user taps your chat button. Everything else is optional.

---

## ✅ Initialize SDK

Initialize the SDK **once** with your bot reference ID and environment before launching chat. For example, do this in `application(_:didFinishLaunchingWithOptions:)` or when your app's session starts.

```swift
NetomiChat.shared.initialize(
    botRefId: "YOUR_BOT_REF_ID",
    env: .USProd
)
```

- `botRefId`: Your Netomi bot reference ID.
- `env`: Netomi environment. Supported values are `.USProd`, `.SGProd`,
  `.EUProd`, `.QA`, `.QAInternal`, and `.Development`.
- `isDynamicEnv`: Optional. Pass `true` only when your bot is configured for
  dynamic SDK configuration.

```swift
NetomiChat.shared.initialize(
    botRefId: "YOUR_BOT_REF_ID",
    env: .QA,
    isDynamicEnv: true
)
```

> The SDK safely ignores duplicate initialization calls that use the same `botRefId`, `env`, and `isDynamicEnv`. If any value changes, the SDK resets its current state and initializes with the new configuration.
>
> 🔹 Most visual styling can be configured via the Netomi Dashboard.
> To customize it locally in code, see [UI Theming](ui-theming.md).

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

## 🚀 Launch Chat

Open the chat directly, or open it with an optional prefilled query. You can also customize the **animation style and duration** using `NCWAnimationConfig`.

> ℹ️ Launch APIs are **fire-and-forget by default**.
> Use `launchAsync()` only if you need confirmation that the UI was shown.

Pick the variant that matches your need:

- **Basic:** open the chat. Recommended for most apps.
- **With error handling:** know if the chat could not be shown.
- **With initial query:** prefill the user's first message.
- **With custom animation:** set a specific open animation or duration.

### 🔹 Basic (Recommended)

```swift
NetomiChat.shared.launch()
```

Use this in most cases. The SDK handles all internal validation and state management.

### 🔹 With Optional Error Handling

```swift
NetomiChat.shared.launch(
    jwt: nil,
    errorHandler: { error in
        print("Chat launch failed:", error)
    }
)
```

- `errorHandler` is invoked **only if the chat cannot be shown**.
- It is **not** a completion callback.

### 🔹 With Initial Query

```swift
NetomiChat.shared.launchWithQuery(
    "Hello, I need help",
    jwt: nil
)
```

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

### 🔹 With Query + Custom Animation

```swift
let animation = NCWAnimationConfig(animationType: .fade, duration: 0.35)

NetomiChat.shared.launchWithQuery(
    "Hello, I need help",
    jwt: nil,
    animationConfig: animation
)
```

### ⚙️ Animation Config

| Option | Description | Default |
| --- | --- | --- |
| `animationType` | `.system`, `.fade`, or other supported preset | `.system` |
| `duration` | Duration of the animation in seconds | `0.3` |

> 🔐 Passing a `jwt` here is only required for authenticated bots. See [Events & Authentication](events-and-auth.md) for details.

---

## 🔹 launchAsync (Advanced)

Use this **only if your app needs to know whether the chat UI was shown**. For example, you might use it to update your own UI state. Otherwise, prefer the fire-and-forget `launch()` above.

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

| Value | Meaning |
| --- | --- |
| `true` | Chat UI was presented. |
| `false` | Chat could not be presented at this time. |

> ℹ️ A `false` return means the SDK was unable to show the chat at this time.
> The SDK internally handles validation, retries, and state coordination.

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

> ℹ️ Async APIs are **optional**. Use them when your app needs to confirm whether the chat UI was presented. The SDK manages internal validation and state automatically.

---

## 🪟 Manage Chat UI Visibility

Once the chat is open, you can check whether it is visible, hide it for later, or destroy it.

> ℹ️ `hideChat` and `resumeChat` are synchronous APIs executed on the main thread.

### 🔹 Check if Chat is Visible

```swift
if NetomiChat.shared.isChatVisible() {
    print("Chat is currently visible")
}
```

### 🔹 Resume a Previously Hidden Chat

```swift
let animation = NCWAnimationConfig(animationType: .fade)
NetomiChat.shared.resumeChat(animationConfig: animation)
```

> If there is no hidden chat to resume, this is a no-op.
> The default animation is `.system` with a `0.3s` duration.

### 🔹 Hide or Destroy Chat

```swift
let animation = NCWAnimationConfig(animationType: .fade, duration: 0.25)
NetomiChat.shared.hideChat(mode: .hide, animationConfig: animation)
```

The `mode` parameter controls what happens to the chat UI:

- `.hide`: Keeps the UI off-screen so it can be resumed later.
- `.destroy`: Tears down the UI so the next open starts fresh.

The `animationConfig` parameter is optional and sets the animation preset and duration.

---

## 🧩 Clear Current Chat Session Manually

Logs out the user and resets the session so the next launch starts clean. Calling this **ends any active conversation**, **dismisses the chat UI if it is currently visible**, and clears the stored session state. Use this, for example, after a user logs out.

```swift
NetomiChat.shared.clearChatSession()
```

---

### ➡️ Next steps

- Style the chat in code → **[UI Theming](ui-theming.md)**
- Push notifications → **[Push Notifications](push-notifications.md)**
- Authenticated sessions → **[Events & Authentication](events-and-auth.md)**
- Configure consent, menus, headers, and logging → **[Advanced](advanced.md)**
- Something not working? → **[Troubleshooting & FAQ](troubleshooting.md)**
