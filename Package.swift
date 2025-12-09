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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.16.1/Netomi.xcframework.zip",
            checksum: "fac752ff3ee14f405cf4a520fe745b42212b873f3bd207a516554b5121cddb57"
        )
    ]
)
