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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.31.0/NetomiCore.xcframework.zip",
            checksum: "632e4c414b5d2c42bcf25a041f92f971587f1589410111da27ab753cc03d7eb0"
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
        )
    ]
)
