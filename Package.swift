// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NetomiChatSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Netomi",
            targets: [
                "Netomi"
            ]
        ),
        .library(
            name: "NetomiAnalytics",
            targets: [
                "NetomiAnalytics"
            ]
        ),
        // Optional: adds Speech-to-Text support via the Microsoft Speech SDK. Link this
        // product in addition to "Netomi" to enable the mic/STT feature.
        .library(
            name: "NetomiVoiceSTT",
            targets: [
                "NetomiVoiceSTT"
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/mixpanel/mixpanel-swift.git",
            .upToNextMajor(from: "6.4.0")
        ),
        // Only the optional "NetomiVoiceSTT" target below depends on this.
        .package(
            url: "https://github.com/microsoft/speech-sdk-spm",
            .upToNextMinor(from: "1.51.1")
        )
    ],
    targets: [
        .binaryTarget(
            name: "NetomiCore",
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.32.1/NetomiCore.xcframework.zip",
            checksum: "7c2e86dd57c40f99edfefd60898bf2ca5334ca206053cfba8b267474952beabf"
        ),
        .target(
            name: "Netomi",
            dependencies: [
                "NetomiCore"
            ],
            path: "Sources/Netomi"
        ),
        .target(
            name: "NetomiAnalytics",
            dependencies: [
                "Netomi",
                "NetomiCore",
                .product(name: "Mixpanel", package: "mixpanel-swift")
            ],
            path: "Sources/NetomiAnalytics"
        ),
        // MARK: - Optional Voice/STT module
        // Only this target depends on the Microsoft Speech SDK; NetomiCore and
        // the "Netomi" target above never reference it.
        .target(
            name: "NetomiVoiceSTT",
            dependencies: [
                "Netomi",
                "NetomiVoiceSTTAutoActivator",
                .product(name: "MicrosoftCognitiveServicesSpeech-iOS", package: "speech-sdk-spm")
            ],
            path: "Sources/NetomiVoiceSTT"
        ),
        // Genuine Objective-C `+load` (Swift can't override NSObject's), in its own target
        // since this SDK's swift-tools-version predates SPM's mixed-language single-target
        // support. See NCWVoiceSTTAutoActivator.m.
        .target(
            name: "NetomiVoiceSTTAutoActivator",
            path: "Sources/NetomiVoiceSTTAutoActivator",
            // Works around an SPM quirk: a Swift target depending on a C-family target that
            // has zero header files fails manifest resolution with "public headers ('include')
            // directory path ... is invalid or not contained in the target" unless a
            // publicHeadersPath is set explicitly, even though this target has no headers to
            // publish (it's a single .m file).
            publicHeadersPath: "."
        )
    ]
)
