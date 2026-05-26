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
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/aws-amplify/aws-sdk-ios-spm.git",
            .upToNextMinor(from: "2.41.0")
        ),
        .package(
            url: "https://github.com/DataDog/dd-sdk-ios.git",
            .upToNextMinor(from: "3.11.0")
        )
    ],
    targets: [
        .binaryTarget(
            name: "NetomiCore",
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.24.1/NetomiCore.xcframework.zip",
            checksum: "7d3372c3c9d440caae91c9bbadefcb2dfc56ca7e7797183e111dccbc8bfbd85e"
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
                .product(name: "AWSIoT", package: "aws-sdk-ios-spm"),
                "MicrosoftCognitiveServicesSpeech"
            ],
            path: "Sources/Netomi"
        ),
        .target(
            name: "NetomiInternal",
            dependencies: [
                .product(name: "DatadogCore", package: "dd-sdk-ios"),
                .product(name: "DatadogLogs", package: "dd-sdk-ios")
            ],
            path: "Sources/NetomiInternal"
        )
    ]
)
