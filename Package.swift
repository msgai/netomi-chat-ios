// swift-tools-version:5.9
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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.24.0/Netomi.xcframework.zip",
            checksum: "89980ac6a3dd8e2d3e8d8f9d79ecd4d9d1e2bc746de63fd0ba865688177b0b5d"
        )
    ]
)
