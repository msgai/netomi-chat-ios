# Events & Authentication

[← Back to documentation index](../README.md)

> **What this guide covers:** identifying users, authenticating them with JWT, receiving events **from** the SDK, and sending events **to** the SDK.
>
> **Read this when:** your bot uses authenticated sessions, or your app needs to react to chat events or send events back to the SDK.

---

## 👤 Guest vs. Authenticated Users

The SDK supports two user models. Which one applies depends on how your **bot** is configured in the Netomi Dashboard.

| | Guest (anonymous) user | Authenticated user |
| --- | --- | --- |
| **When to use** | Default. Your bot does not require sign-in. | Your bot is configured for authenticated sessions. |
| **JWT** | Not required — pass `nil` (or omit it). | A valid JWT is required at launch and on reauthorization. |
| **Identity** | The SDK manages an anonymous session. | The JWT identifies the user to the Netomi backend. |
| **Typical call** | `NetomiChat.shared.launch()` | `NetomiChat.shared.launch(jwt: "your-jwt-token")` |

> ℹ️ There is no separate "login" API. A user is treated as **authenticated** when you launch the chat with a valid JWT for a bot configured to require one; otherwise the session is a **guest** session.

### Identifying the user (both models)

You can attach your own user attributes to either a guest or an authenticated session using custom parameters. This personalizes the experience and forwards metadata to the AI backend — it does **not** authenticate the user on its own.

```swift
NetomiChat.shared.setCustomParameter([
    "user_id": "12345",
    "membership_level": "gold"
])
```

> ⚠️ Custom parameters are metadata, not credentials. For authenticated bots, identity is still established by the JWT. Do not put secrets in custom parameters. See **[Advanced](advanced.md)** for the full custom-parameter API.

### Switching users / logging out

When the signed-in user changes or logs out, call `clearChatSession()` so the next launch starts clean. This ends any active conversation, dismisses the chat UI if it is visible, and clears the stored session state:

```swift
NetomiChat.shared.clearChatSession()
```

Then launch again with the new user's JWT (authenticated) or with no JWT (guest).

---

## 🔐 JWT Authentication (Optional)

Pass a JWT when launching the chat if your bot is configured for authenticated sessions:

```swift
NetomiChat.shared.launch(jwt: "your-jwt-token")
```

- A JWT is required **only** if your bot is configured for authenticated sessions.
- Passing a JWT when not required is safely ignored.

### When is a JWT required?

- `launch(jwt:)`: Optional. Use when your bot requires authentication; otherwise pass `nil`.
- `launchWithQuery(_:jwt:)`: Optional. Same as `launch(jwt:)`.
- `launchAsync(jwt:)`: Optional. Async variant of `launch`.
- `launchWithQueryAsync(_:jwt:)`: Optional. Async variant with a prefilled query.
- `.reauthorizationSuccess`: Required if the session was started with JWT.
- `.reauthorizationFailure`: Optional. You can omit the JWT.
- Other events: Optional. The JWT is ignored if it is not applicable.

---

## 🔔 Event Handling

The SDK communicates with your app in **two directions**:

- **SDK → app:** the SDK notifies you about chat activity, including opened,
  reauthorization requested, and errors.
- **App → SDK:** you send the SDK a response or a custom event, such as the
  result of a reauthorization.

### Receive Events from SDK

Assign a handler to be called whenever the SDK emits an event:

```swift
NetomiChat.shared.getEventUpdatesFromSDK = { [weak self] event in
    guard let self else { return }

    let eventTypeKey = NCWPublicEventKeys.eventType.rawValue
    guard let typeString = event[eventTypeKey] as? String,
            let eventType = NCWPublicEvent(rawValue: typeString) else {
        return
    }

    let eventDataKey = NCWPublicEventKeys.eventData.rawValue
    let eventData = event[eventDataKey] as? [String: Any] ?? [:]

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

Use `sendEventToSdk(type:eventName:jwt:data:)` when the SDK expects a response from the host app, such as JWT reauthorization. You can also use it to send a supported custom event.

> 🔁 **Reauthorization flow:** the SDK emits `.reauthorizationRequest`, your
> app re-authenticates the user, then your app responds with
> `.reauthorizationSuccess` (with a fresh JWT) or `.reauthorizationFailure`.

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

#### Parameters

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

| Event Type | Description |
| --- | --- |
| `.reauthorizationSuccess` | Reauthorization completed successfully. |
| `.reauthorizationFailure` | Reauthorization failed. |
| `.custom` | Vendor/app-specific event. Requires `eventName`. |

---

### ➡️ Related

- Launch the chat (with or without a JWT) → **[Usage](usage.md)**
- Pass extra metadata or custom headers → **[Advanced](advanced.md)**
- JWT handling, consent, and PII → **[Security & Privacy](security-and-privacy.md)**
- Auth or event issues? → **[Troubleshooting & FAQ](troubleshooting.md)**
