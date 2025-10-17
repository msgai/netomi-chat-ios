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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.11.0/Netomi.xcframework.zip",
            checksum: "8e4382bac275a70f07f6fa2f73d979b83c5311e4f9c0634987a5a284ab206d3d"
        )
    ]
)
