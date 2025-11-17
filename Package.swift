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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.14.0/Netomi.xcframework.zip",
            checksum: "ca50c50e208b1b8168bfcce76cd73039e134f4b7e017f6df7b08e3a40f29cf85"
        )
    ]
)
