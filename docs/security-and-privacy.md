# Security & Privacy

[← Back to documentation index](../README.md)

> **What this guide covers:** how the SDK handles tracking consent and privacy, what its bundled privacy manifest declares, and best practices for keeping sensitive data out of the SDK.
>
> **Read this when:** you are preparing an App Store submission, completing a privacy review, or hardening your integration.

---

## 🔒 Tracking consent

The SDK exposes a runtime consent control so your app can honor a user's privacy choice. Set it whenever the user's consent state is known or changes.

```swift
NetomiChat.shared.setTrackingConsent(.granted)
```

| Value | Meaning |
| --- | --- |
| `.granted` | The user has consented to SDK observability. |
| `.notGranted` | The user has declined. |
| `.pending` | Consent has not been decided yet. |

- Consent controls SDK observability (such as diagnostics/analytics behavior) at runtime.
- You can change the value at any time; the most recent value applies.
- This setting is independent of Apple's App Tracking Transparency (ATT). The SDK's bundled privacy manifest declares **no tracking** (see below). If your wider app performs tracking, manage ATT yourself.

> See **[Advanced](advanced.md)** for where `setTrackingConsent(_:)` fits alongside the other runtime controls.

---

## 📄 Privacy manifest

The SDK ships an Apple **privacy manifest** (`PrivacyInfo.xcprivacy`) describing its data and API usage. It declares:

- **Collected data types:** none declared by the SDK.
- **Tracking:** `NSPrivacyTracking` is `false`; no tracking domains are declared.
- **Required-reason API usage:**
  - `UserDefaults` — used for SDK state/preferences.
  - File timestamp APIs — used for file/media handling.

> When you submit your app, Xcode aggregates privacy manifests from your app and its SDKs into the App Store privacy report. You are still responsible for declaring any data **your app** collects, including any user attributes you pass to the SDK (see below).

---

## 🔐 Authentication & sessions

- For bots configured for authenticated sessions, identity is established with a **JWT** you provide at launch and on reauthorization. See **[Events & Authentication](events-and-auth.md)**.
- Treat JWTs as short-lived credentials: generate them server-side, scope them to the user, and refresh them through the reauthorization flow rather than embedding long-lived tokens in the app.
- Use `clearChatSession()` when a user logs out or switches accounts so the next session starts clean.

---

## 🧾 Keep secrets out of the SDK

Some APIs forward data to the AI backend or attach it to network requests. Send only what you need, and never send secrets.

- **Custom parameters** (`setCustomParameter(_:)` / `sendCustomParameter(name:value:)`) are metadata used to personalize the conversation. They are **not** credentials and do not authenticate the user. Do not put passwords, tokens, or secrets in them.
- **Custom API headers** (`updateApiHeaderConfiguration(headers:)`) are sent with each SDK API call. Avoid placing long-lived secrets here; prefer short-lived, scoped values.
- Avoid sending personally identifiable information (PII) unless your privacy policy and bot configuration call for it.

> ⚠️ Anything you pass through custom parameters or headers may be transmitted off-device. Apply the same data-minimization rules you use for your own APIs.

---

## ✅ Pre-submission checklist

- [ ] Set tracking consent (`setTrackingConsent(_:)`) according to your consent UX.
- [ ] Confirm your app's own `PrivacyInfo.xcprivacy` declares any data **your app** collects, including attributes you pass to the SDK.
- [ ] Generate JWTs server-side and refresh via the reauthorization flow.
- [ ] Verify no secrets are passed via custom parameters or custom headers.
- [ ] Keep SDK logging at `.none` in production (see **[Advanced](advanced.md)**).

---

### ➡️ Related

- Runtime controls (consent, headers, logging) → **[Advanced](advanced.md)**
- JWT auth and reauthorization → **[Events & Authentication](events-and-auth.md)**
- Something not working? → **[Troubleshooting & FAQ](troubleshooting.md)**
