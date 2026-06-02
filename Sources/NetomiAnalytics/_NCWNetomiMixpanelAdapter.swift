import Foundation
import Mixpanel

final class _NCWNetomiMixpanelAdapter: NSObject {

    private static let mixpanelClient = _NCWDefaultMixpanelClient()

    #if DEBUG
    private static var testHooks: _NCWMixpanelTestHooks?

    static func setTestHooksForTesting(_ hooks: _NCWMixpanelTestHooks?) {
        testHooks = hooks
    }
    #endif

    @objc(netomi_initializeWithToken:trackAutomaticEvents:)
    func initialize(token: NSString, trackAutomaticEvents: NSNumber) {
        #if DEBUG
        if let testHooks = Self.testHooks {
            testHooks.initialize(token as String, trackAutomaticEvents.boolValue)
            return
        }
        #endif

        Self.mixpanelClient.initialize(
            token: token as String,
            trackAutomaticEvents: trackAutomaticEvents.boolValue
        )
    }

    @objc(netomi_trackWithEvent:properties:)
    func track(event: NSString, properties: NSDictionary?) {
        let mixpanelProperties = (properties as? [String: Any])?
            .compactMapValues { $0 as? MixpanelType }

        #if DEBUG
        if let testHooks = Self.testHooks {
            testHooks.track(event as String, mixpanelProperties)
            return
        }
        #endif

        Self.mixpanelClient.track(
            event: event as String,
            properties: mixpanelProperties
        )
    }

    @objc(netomi_timeWithEvent:)
    func time(event: NSString) {
        #if DEBUG
        if let testHooks = Self.testHooks {
            testHooks.time(event as String)
            return
        }
        #endif

        Self.mixpanelClient.time(event: event as String)
    }

    @objc(netomi_flush)
    func flush() {
        #if DEBUG
        if let testHooks = Self.testHooks {
            testHooks.flush()
            return
        }
        #endif

        Self.mixpanelClient.flush()
    }
}

#if DEBUG
struct _NCWMixpanelTestHooks {
    let initialize: (String, Bool) -> Void
    let track: (String, [String: MixpanelType]?) -> Void
    let time: (String) -> Void
    let flush: () -> Void
}
#endif

struct _NCWDefaultMixpanelClient {
    func initialize(token: String, trackAutomaticEvents: Bool) {
        Mixpanel.initialize(
            token: token,
            trackAutomaticEvents: trackAutomaticEvents
        )
    }

    func track(event: String, properties: [String: MixpanelType]?) {
        Mixpanel.mainInstance().track(
            event: event,
            properties: properties
        )
    }

    func time(event: String) {
        Mixpanel.mainInstance().time(event: event)
    }

    func flush() {
        Mixpanel.mainInstance().flush()
    }
}
