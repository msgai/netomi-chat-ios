// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "NetomiChatSDK",
    platforms: [
        .iOS(.v15)
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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.4.3/Netomi.xcframework.zip",
            checksum: "1a90df33476a58963aecfe8e478f71e784830a89702c9f9370b9572cb7b5a2ba"
        )
    ]
)
