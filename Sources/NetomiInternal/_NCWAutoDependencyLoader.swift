import Foundation

@objc public final class _NCWAutoDependencyLoader: NSObject {

    @objc public static func loadDependencies() {
        _ = _NCWNetomiDatadogAdapter.self
        _ = _NCWInternalLottieView.self
    }

    @objc public static func makeObservabilityAdapter() -> NSObject {
        _NCWNetomiDatadogAdapter()
    }

    @objc public static func makeAnimationView() -> NSObject? {
        _NCWInternalLottieView()
    }
}
