import Foundation

/// Internal facade used by the distribution bridge.
///
/// App integrations should import and use `Netomi`; this target only wires
/// optional dependencies into the core SDK.
enum NetomiInternal {

    static func loadDependencies() {
        _NCWAutoDependencyLoader.loadDependencies()
    }
}
