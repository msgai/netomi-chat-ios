// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "NetomiChatSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NetomiChatSDK",
            targets: ["Netomi"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "Netomi",
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.4.4/Netomi.xcframework.zip",
            checksum: "1075ff2e4b2cede23f9d92d529e1d5eba771d32e3364c1421c613d03ec1cfbc4"
        )
    ]
)
