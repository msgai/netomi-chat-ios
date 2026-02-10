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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.18.0/Netomi.xcframework.zip",
            checksum: "c5f028fff6766de6e4af31b46a0da102f555c1b19b058ac9e7ac0d038b27f7c2"
        )
    ]
)
