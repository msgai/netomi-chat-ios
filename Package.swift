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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.1.14/Netomi.xcframework.zip",
            checksum: "86e10039bacd6d5ca6e4346c9855c40957115fc54297cdf9c7a1e62a10f613f1"
        )
    ]
)
