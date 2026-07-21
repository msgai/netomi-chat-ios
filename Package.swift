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
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/airbnb/lottie-spm.git",
            .upToNextMinor(from: "4.6.0")
        ),
        .package(
            url: "https://github.com/mixpanel/mixpanel-swift.git",
            .upToNextMajor(from: "6.4.0")
        )
    ],
    targets: [
        .binaryTarget(
            name: "NetomiCore",
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.29.1/NetomiCore.xcframework.zip",
            checksum: "c3ebba61d4ef1fea8b3e3ac37774e40936334454cf0e20850c12d1e482e4e2c1"
        ),
        .binaryTarget(
            name: "MicrosoftCognitiveServicesSpeech",
            url: "https://csspeechstorage.blob.core.windows.net/drop/1.49.1/MicrosoftCognitiveServicesSpeech-XCFramework-1.49.1.zip",
            checksum: "6166a6338a55d4fe5e98e67460d21d5e725a7dd47268fc3648113de866f4a780"
        ),
        .target(
            name: "Netomi",
            dependencies: [
                "NetomiCore",
                "NetomiInternal",
                "MicrosoftCognitiveServicesSpeech"
            ],
            path: "Sources/Netomi"
        ),
        .target(
            name: "NetomiInternal",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm")
            ],
            path: "Sources/NetomiInternal"
        ),
        .target(
            name: "NetomiAnalytics",
            dependencies: [
                "Netomi",
                "NetomiCore",
                .product(name: "Mixpanel", package: "mixpanel-swift")
            ],
            path: "Sources/NetomiAnalytics"
        )
    ]
)
