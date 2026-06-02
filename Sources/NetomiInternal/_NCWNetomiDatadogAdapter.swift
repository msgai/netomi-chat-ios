import DatadogCore
import DatadogLogs
import Foundation

final class _NCWNetomiDatadogAdapter: NSObject {

    private static let datadogClient = _NCWDefaultDatadogClient()

    #if DEBUG
    private static var testHooks: _NCWDatadogTestHooks?

    static func setTestHooksForTesting(_ hooks: _NCWDatadogTestHooks?) {
        testHooks = hooks
    }
    #endif

    private var logHandler: ((LogLevel, String, [String: Encodable]) -> Void)?
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

        #if DEBUG
        if let testHooks = Self.testHooks {
            testHooks.initialize(token, environmentName, serviceName, backgroundTasksEnabled, trackingConsent)

            if debugVerbosityEnabled {
                testHooks.setDebugVerbosity()
            }

            if isLogsEnabled {
                logHandler = testHooks.makeLogger(
                    serviceName,
                    loggerName,
                    isNetworkInfoEnabled,
                    sampleRate,
                    configuration.stringValue(forKey: "logSeverityThreshold").datadogLogLevel
                )
            }

            isConfigured = true
            return
        }
        #endif

        Self.datadogClient.initialize(
            token: token,
            environmentName: environmentName,
            serviceName: serviceName,
            backgroundTasksEnabled: backgroundTasksEnabled,
            trackingConsent: trackingConsent
        )

        if debugVerbosityEnabled {
            Self.datadogClient.setDebugVerbosity()
        }

        if isLogsEnabled {
            let logger = Self.datadogClient.makeLogger(
                serviceName: serviceName,
                loggerName: loggerName,
                networkInfoEnabled: isNetworkInfoEnabled,
                sampleRate: sampleRate,
                logLevel: configuration.stringValue(forKey: "logSeverityThreshold").datadogLogLevel
            )
            logHandler = logger.log
        }

        isConfigured = true
    }

    @objc(netomi_setTrackingConsent:)
    func setTrackingConsent(_ consent: NSString) {
        guard isConfigured else { return }

        #if DEBUG
        if let testHooks = Self.testHooks {
            testHooks.setTrackingConsent(Optional(consent as String).datadogTrackingConsent)
            return
        }
        #endif

        Self.datadogClient.setTrackingConsent(Optional(consent as String).datadogTrackingConsent)
    }

    @objc(netomi_logWithRecord:)
    func log(_ record: NSObject) {
        guard isConfigured, let logHandler else { return }

        let message = record.stringValue(forKey: "message") ?? ""
        let level = record.stringValue(forKey: "level").datadogLogLevel
        let attributes = record.dictionaryValue(forKey: "attributes")?.encodableAttributes ?? [:]

        logHandler(level, message, attributes)
    }

    @objc(netomi_reset)
    func reset() {
        logHandler = nil
        isConfigured = false
    }
}

#if DEBUG
struct _NCWDatadogTestHooks {
    let initialize: (String, String, String, Bool, TrackingConsent) -> Void
    let setTrackingConsent: (TrackingConsent) -> Void
    let setDebugVerbosity: () -> Void
    let makeLogger: (String, String, Bool, Double, LogLevel) -> (LogLevel, String, [String: Encodable]) -> Void
}
#endif

struct _NCWDefaultDatadogClient {
    func initialize(token: String, environmentName: String, serviceName: String, backgroundTasksEnabled: Bool, trackingConsent: TrackingConsent) {
        let configuration = Datadog.Configuration(
            clientToken: token,
            env: environmentName,
            service: serviceName,
            backgroundTasksEnabled: backgroundTasksEnabled
        )

        Datadog.initialize(
            with: configuration,
            trackingConsent: trackingConsent
        )
    }

    func setTrackingConsent(_ trackingConsent: TrackingConsent) {
        Datadog.set(trackingConsent: trackingConsent)
    }

    func setDebugVerbosity() {
        Datadog.verbosityLevel = .debug
    }

    func makeLogger(serviceName: String, loggerName: String, networkInfoEnabled: Bool, sampleRate: Double, logLevel: LogLevel) -> _NCWDefaultDatadogLogger {
        Logs.enable()
        return _NCWDefaultDatadogLogger(logger: Logger.create(
            with: Logger.Configuration(
                service: serviceName,
                name: loggerName,
                networkInfoEnabled: networkInfoEnabled,
                bundleWithRumEnabled: false,
                bundleWithTraceEnabled: false,
                remoteSampleRate: Float(sampleRate),
                remoteLogThreshold: logLevel,
                consoleLogFormat: .shortWith(prefix: "[iOS App]")
            )
        ))
    }
}

struct _NCWDefaultDatadogLogger {
    let logger: LoggerProtocol

    func log(level: LogLevel, message: String, attributes: [String: Encodable]) {
        logger.log(
            level: level,
            message: message,
            error: nil,
            attributes: attributes
        )
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
