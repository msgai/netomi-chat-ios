import Foundation

@objc public final class _NCWAutoDependencyLoader: NSObject {

    @objc public static func loadDependencies() {
        _ = _NCWNetomiDatadogAdapter.self
    }

    @objc public static func makeObservabilityAdapter() -> NSObject {
        _NCWNetomiDatadogAdapter()
    }
}
