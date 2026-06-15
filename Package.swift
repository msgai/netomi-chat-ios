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
            url: "https://github.com/aws-amplify/aws-sdk-ios-spm.git",
            .upToNextMinor(from: "2.41.0")
        ),
        .package(
            url: "https://github.com/DataDog/dd-sdk-ios.git",
            .upToNextMinor(from: "3.11.0")
        ),
        .package(
            url: "https://github.com/airbnb/lottie-ios.git",
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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.25.0/NetomiCore.xcframework.zip",
            checksum: "06381877add9c22f34e7a36d5881e325711015a124b2574e735cb7977f5b0ec2"
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
                .product(name: "DatadogLogs", package: "dd-sdk-ios"),
                .product(name: "Lottie", package: "lottie-ios")
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
