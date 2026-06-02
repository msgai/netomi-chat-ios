import Foundation

/// Forces the linker to keep this loader available for runtime lookup.
private let _netomiInternalLinkAnchor: AnyClass = _NCWAnalyticsDependencyLoader.self

/// Enables optional analytics provider integrations for Netomi.
public enum NetomiAnalyticsSupport {

    /// Call before initializing `NetomiChat` when analytics support is installed.
    public static func enable() {
        _NCWAnalyticsDependencyLoader.loadDependencies()
    }
}

public final class _NCWAnalyticsDependencyLoader: NSObject {

    @objc public static func loadDependencies() {
        _ = _NCWNetomiMixpanelAdapter.self
    }

    @objc public static func makeAnalyticsAdapter() -> NSObject {
        _NCWNetomiMixpanelAdapter()
    }
}
