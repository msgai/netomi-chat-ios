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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.4.2/Netomi.xcframework.zip",
            checksum: "63c9de9f63d9243ca4c053803a46fb6ec06e4bdd2a776d0f69f8ac2818b063c1"
        )
    ]
)
