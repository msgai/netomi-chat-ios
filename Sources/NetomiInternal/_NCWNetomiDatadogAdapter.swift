import DatadogCore
import DatadogLogs
import Foundation

final class _NCWNetomiDatadogAdapter: NSObject {

    private var logger: LoggerProtocol?
    private var isConfigured = false

    @objc override init() {
        super.init()
    }

    @objc(netomi_configureWithConfiguration:)
    func configure(_ configuration: NSObject) {
        guard let token = configuration.stringValue(forKey: "token"),
              let environmentName = configuration.stringValue(forKey: "environmentName"),
              let serviceName = configuration.stringValue(forKey: "serviceName"),
              let loggerName = configuration.stringValue(forKey: "loggerName")
        else {
            return
        }

        let backgroundTasksEnabled = configuration.boolValue(forKey: "backgroundTasksEnabled") ?? true
        let debugVerbosityEnabled = configuration.boolValue(forKey: "debugVerbosityEnabled") ?? false
        let isLogsEnabled = configuration.boolValue(forKey: "isLogsEnabled") ?? false
        let isNetworkInfoEnabled = configuration.boolValue(forKey: "isNetworkInfoEnabled") ?? false
        let sampleRate = configuration.doubleValue(forKey: "sampleRate") ?? 100
        let trackingConsent = configuration.stringValue(forKey: "trackingConsent").datadogTrackingConsent

        let datadogConfiguration = Datadog.Configuration(
            clientToken: token,
            env: environmentName,
            service: serviceName,
            backgroundTasksEnabled: backgroundTasksEnabled
        )

        Datadog.initialize(
            with: datadogConfiguration,
            trackingConsent: trackingConsent
        )

        if debugVerbosityEnabled {
            Datadog.verbosityLevel = .debug
        }

        if isLogsEnabled {
            Logs.enable()
            logger = Logger.create(
                with: Logger.Configuration(
                    service: serviceName,
                    name: loggerName,
                    networkInfoEnabled: isNetworkInfoEnabled,
                    bundleWithRumEnabled: false,
                    bundleWithTraceEnabled: false,
                    remoteSampleRate: Float(sampleRate),
                    remoteLogThreshold: configuration.stringValue(forKey: "logSeverityThreshold").datadogLogLevel,
                    consoleLogFormat: .shortWith(prefix: "[iOS App]")
                )
            )
        }

        isConfigured = true
    }

    @objc(netomi_setTrackingConsent:)
    func setTrackingConsent(_ consent: NSString) {
        guard isConfigured else { return }
        Datadog.set(trackingConsent: Optional(consent as String).datadogTrackingConsent)
    }

    @objc(netomi_logWithRecord:)
    func log(_ record: NSObject) {
        guard isConfigured, let logger else { return }

        let message = record.stringValue(forKey: "message") ?? ""
        let level = record.stringValue(forKey: "level").datadogLogLevel
        let attributes = record.dictionaryValue(forKey: "attributes")?.encodableAttributes ?? [:]

        logger.log(
            level: level,
            message: message,
            error: nil,
            attributes: attributes
        )
    }

    @objc(netomi_reset)
    func reset() {
        logger = nil
        isConfigured = false
    }
}

private extension NSObject {
    func stringValue(forKey key: String) -> String? {
        guard hasReadableKey(key),
              let value = value(forKey: key) as? String,
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return value
    }

    func boolValue(forKey key: String) -> Bool? {
        guard hasReadableKey(key) else { return nil }
        return value(forKey: key) as? Bool
    }

    func doubleValue(forKey key: String) -> Double? {
        guard hasReadableKey(key) else { return nil }
        return value(forKey: key) as? Double
    }

    func dictionaryValue(forKey key: String) -> [String: Any]? {
        guard hasReadableKey(key) else { return nil }
        return value(forKey: key) as? [String: Any]
    }

    private func hasReadableKey(_ key: String) -> Bool {
        responds(to: NSSelectorFromString(key))
    }
}

private extension Optional where Wrapped == String {
    var datadogTrackingConsent: TrackingConsent {
        switch self?.uppercased() {
        case "PENDING": return .pending
        case "NOTGRANTED": return .notGranted
        default: return .granted
        }
    }

    var datadogLogLevel: LogLevel {
        switch self?.lowercased() {
        case "debug": return .debug
        case "notice": return .notice
        case "warn": return .warn
        case "error": return .error
        case "critical": return .critical
        default: return .info
        }
    }
}

private extension Dictionary where Key == String, Value == Any {
    var encodableAttributes: [String: Encodable] {
        compactMapValues { value in
            value as? Encodable
        }
    }
}
