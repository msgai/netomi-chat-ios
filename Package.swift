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
            url: "https://github.com/mixpanel/mixpanel-swift.git",
            .upToNextMajor(from: "6.4.0")
        )
    ],
    targets: [
        .binaryTarget(
            name: "NetomiCore",
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.29.2/NetomiCore.xcframework.zip",
            checksum: "de0c692c11f8647dbeeba51d6dc0bf192f9f233987f782b02d7b3bfa68032b20"
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
                "MicrosoftCognitiveServicesSpeech"
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
        )
    ]
)
