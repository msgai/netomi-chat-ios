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
  closed, reauthorization requested, and errors.
- **App → SDK:** you send the SDK a response or a custom event, such as the
  result of a reauthorization.

### Receive Events from SDK

Assign a handler to be called whenever the SDK emits an event:

> ℹ️ **Delivery is asynchronous.** `getEventUpdatesFromSDK` is always invoked on the main
> thread, but the call is deferred — the SDK operation that triggers an event (e.g. the
> chat opening, a message being sent) can return to its own caller before your closure
> actually runs. Don't assume the closure has fired by the time a triggering call
> completes. Events are still delivered in the exact order they occurred, even when
> triggered from different background threads — you never need to sort or de-duplicate
> based on arrival order.

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

    // For `.customEvent`, the actual event name is nested inside `eventData`,
    // under the same `eventType` key — not on the outer `event` dictionary.
    let eventName = eventData[NCWPublicEventKeys.eventType.rawValue] as? String

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
        // `flow_completed` is false when the request failed or the server rejected the new JWT.
        let completed = eventData[NCWPublicEventKeys.flowCompleted.rawValue] as? Bool ?? false
        print("Reauthorization response received, completed:", completed)

    case .chatOpened:
        print("Chat opened")

    case .chatClosed:
        print("Chat closed")

    case .error:
        print("SDK error event:", eventData)
        // Initialization failures carry event_sub_type "initialization_error",
        // launch failures carry "launch_error". Details are in event_payload.
        // Sensitive values in the details are masked ("***") before delivery.
        // See "Initialization error events" and "Launch error events" below.

    case .customEvent:
        // Bot-driven custom events (e.g. a CALLBACK_EVENT sent from your bot flow) arrive here.
        print("Custom event received: \(eventName ?? "unknown") — payload:", eventData)

    default:
        break
    }
}
```

### Initialization error events

When `initialize(...)` fails, the SDK emits an `.error` event even if you did not pass an `errorHandler`. The event has the same details the handler receives:

```swift
case .error:
    let subType = eventData[NCWPublicEventKeys.eventSubType.rawValue] as? String
    if subType == "initialization_error" {
        let details = eventData[NCWPublicEventKeys.eventPayload.rawValue] as? [String: Any]
        print("Initialization failed:", details?["exceptionCode"] ?? "-", details?["statusMessage"] ?? "-")
    }
```

| Key | Description |
| --- | --- |
| `event_sub_type` | `initialization_error` for these events (`launch_error` for [launch errors](#launch-error-events)). Other `.error` events do not carry this value. |
| `event_payload` | Dictionary with `type`, `statusCode`, `statusMessage`, `error` and `exceptionCode`. Fields without a value are omitted. |
| `error_details` | A single readable summary string, for example `Code: 403 \| Bot reference ID is invalid or not found.`. |

> ℹ️ A failed initialization can also produce a general `.error` event describing the failed request. Use `event_sub_type` to tell the two apart. The values are listed in [Usage](usage.md#optional-handle-initialization-errors).

---

### Launch error events

When `launch(...)` cannot show the chat, the SDK emits an `.error` event even if you did not pass an `errorHandler`. It has the same details the handler receives, in the same format as [initialization error events](#initialization-error-events), with `event_sub_type` set to `launch_error`.

```swift
case .error:
    let subType = eventData[NCWPublicEventKeys.eventSubType.rawValue] as? String
    if subType == "launch_error" {
        let details = eventData[NCWPublicEventKeys.eventPayload.rawValue] as? [String: Any]
        print("Launch failed:", details?["exceptionCode"] ?? "-", details?["statusMessage"] ?? "-")
    }
```

### Sensitive values in error events

Error text can echo parts of a request or response. Before an `.error` event is delivered to `getEventUpdatesFromSDK`, the SDK replaces sensitive values in `error_details` and in the text fields of `event_payload` with `***`. This covers tokens, API keys, passwords and passphrases, authorization header values (Bearer, Basic and Digest), session identifiers, one-time and verification codes, AWS access key ids, signed URLs and their signing parameters (S3 `X-Amz-*` signing parameters, CloudFront `Signature`, `Policy` and `Key-Pair-Id`, GCS `X-Goog-Signature` and `X-Goog-Credential`, and any value under `presigned_url`, `signed_url` or `x-cdn-url`), passwords inside URLs (`https://user:password@host`), key material, cookies (`cookie`, `set-cookie`), credentials and user identifiers (`credentials`, `x-user-id`, `x-csrf-token`, `customer_id`, `bot_ref_id`), personal and financial data (`email`, `phone`, `phone_number`, `mobile_number`, `dob`, `date_of_birth`, `iban`, `routing_number`, `account_number`, `bank_account`, `pan`, `card_number`, `credit_card`, `creditCardNumber`, `expiry_date`, `cvv`, `cvc`, `ssn`), US identifiers (`social_security_number`, `tax_id`, `tin`, `itin`, `ein`, `driver_license`, `drivers_license`, `license_number`, `passport`, `passport_number`), health and insurance numbers (`medical_record_number`, `mrn`, `medicare_number`, `medicaid_number`, `mbi`, `insurance_id`, `policy_number`), postal addresses (`street_address`, `home_address`, `billing_address`, `shipping_address`, `mailing_address`, `zip_code`, `postal_code`), phone numbers, and Social Security numbers written as `123-45-6789` even with no key before them. Keys are matched in any case and with `-`, `_` or camelCase spelling (`Customer-Id`, `customerId` and `CUSTOMER_ID` are the same key), and even with a prefix (`user_token`, `dbPassword`, `userEmail`). Keys of three letters or fewer, such as `key`, `pin` and `pan`, and `phone` match only as a whole word, so fields such as `keyboard`, `span` or `microphone` are not masked. An unquoted `key=value` value is masked through any `,`, `)` or `}` in it; for passwords, cookies and postal addresses it is masked to the end of the line, for signed-URL keys the whole URL is masked, and for card, account, phone, Social Security and tax numbers the whole number is masked even when it contains spaces. The `errorHandler` of `initialize(...)` and `launch(...)` receives the same masked values, so the handler and the event stay identical.

| Before masking | You receive |
| --- | --- |
| `rejected token=abc123` | `rejected token="***"` |
| `Authorization: Bearer eyJhbGci...` | `Authorization: "***"` |
| `rejected Bearer abc123` (any length) | `rejected Bearer ***` |
| `x-api-key: abc123` | `x-api-key: "***"` |
| `Invalid token: eyJhbGci...` | `Invalid token: ***` |
| `https://admin:s3cret@db.example.com/path` | `https://admin:***@db.example.com/path` |
| `AKIAIOSFODNN7EXAMPLE rejected` | `*** rejected` |
| `password: hunter2` | `password: ***` |
| `call +1 415-555-2671` or `call (415) 555-2671` | `call ***` |
| `card_number=4111 1111 1111 1111` | `card_number="***"` |
| `Cookie: session=abc123; theme=dark` | `Cookie: "***"` |
| `presignedUrl=https://b.s3.amazonaws.com/f?X-Amz-Signature=abc&X-Amz-Date=20261117T000000Z` | `presignedUrl="***"` |
| `https://cdn.example.com/f?Expires=1700000000&Signature=abc&Key-Pair-Id=APKA1` | `https://cdn.example.com/f?Expires=1700000000&Signature="***"&Key-Pair-Id="***"` |
| `SSN on file 123-45-6789`, `taxId: 12-3456789` | `SSN on file ***`, `taxId: "***"` |
| `email: jane@example.com`, `customerId: C-42` | `email: ***`, `customerId: "***"` |
| `Invalid email: must contain @` | `Invalid email: must contain @` (unchanged) |
| `Invalid token: expired` | `Invalid token: expired` (unchanged) |
| Payload field `"token": "abc123"` or `"token": {"inner": "abc"}` | Same field, value `***` |

A masked `key=value` or `key: value` pair is usually written with quotes around the mask (`token="***"`). If you parse error text, expect the quotes. The exception is the `word: value` form of the ordinary words listed below, which is written without quotes (`password: ***`).

The event shape, `event_sub_type`, `conversation_id`, `statusCode` and `exceptionCode` are not changed, and text without sensitive values arrives as it was. Ordinary words such as `token`, `key`, `secret`, `password`, `jwt`, `policy`, `bucket`, `otp`, `pin`, `signature`, `passphrase`, `credentials`, `email`, `phone`, `pan`, `dob` or `passport` always hide the value after them in `name=value` or quoted JSON (`"name": "value"`) form. In `name: value` form they hide it only when it looks like a credential or personal data: quoted, containing a digit, 20 or more characters long, or, after `email`, containing `@`. Descriptive text such as `Missing key: botId` or `Invalid email: must contain @` therefore stays readable. Phone numbers are masked only when they are phone-shaped (an international `+` number, or `415-555-2671`, `415.555.2671`, `415 555 2671`, `(415) 555-2671`, optionally with a `+<country>` or `1` prefix) and hold at least 7 digits. Timestamps and offsets (`2026-11-13T10:00:00+05:30`), IP addresses, UUIDs, version strings and plain digit runs such as order numbers stay readable, and so does a card number with no `card_number`-style key before it. The same rules apply to the SDK's console logs.

Key names match in any case and with `-`, `_` or camelCase spellings (`api_key`, `apiKey` and `X-API-Key` are the same key). Values the SDK cannot inspect, such as raw binary data inside an event payload, arrive as `***`. Event text and payloads are always delivered, masked rather than dropped.

---

#### JWT rejected mid-chat

When the server rejects the user's JWT (HTTP 401) during an active chat, the SDK sends an `error` event, then shows its session-expired alert and closes the chat. This applies to any request the chat sends, including messages, feedback, surveys, restart and closing an external-link webview. If the user is ending the chat themselves, the chat ends as usual and you still get the `error` event, but no alert is shown. If the End Chat request itself is rejected, the chat closes straight away without waiting for the bot's reply, so the end-chat survey is not shown. If the user's answer to the end-chat survey, or their skip, is rejected, the chat also closes straight away and `.surveySubmitted` / `.surveySkipped` is not sent: you get only the `error` event.

- Sent before the alert, once per chat even if several requests fail together.
- After a successful reauthorization, a later rejection sends the event again and shows the alert. If the alert is already showing, a late rejection from an earlier request is ignored.
- If the server rejects the JWT you sent with `.reauthorizationSuccess`, you get `.reauthorizationResponse` with `flow_completed` set to `false`, then this `error` event, then the alert. Don't treat that `.reauthorizationResponse` as a completed reauthorization.
- `event_sub_type`: `invalid_auth_token_error`. Use this stable value for error handling, logging and analytics.
- `error_details`: the server's message, or a fixed text starting with `JWT rejected (401)`. Don't match on it.
- `conversation_id`: included when a conversation exists.

```swift
case .error:
    let subType = eventData[NCWPublicEventKeys.eventSubType.rawValue] as? String
    let details = eventData[NCWPublicEventKeys.errorDetails.rawValue] as? String
    if subType == "invalid_auth_token_error" {
        // Log `details` and re-authenticate the user before the next launch.
    }
```

#### Attachment clicked

The SDK sends `attachment_clicked` when the user taps the attach button in the chat input and the attachment options sheet opens.

- Sent once per sheet that opens. Taps while the sheet is already open or closing do not send it again.
- Not sent when the sheet cannot open, for example when file sharing is disabled for the bot.
- Upload buttons inside forms open the same sheet but do not send this event.

```swift
case .attachmentClicked:
    // One event per opened attachment sheet; safe to count directly in a funnel.
    print("Attachment options opened")
```

---
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
