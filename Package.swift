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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.15.0/Netomi.xcframework.zip",
            checksum: "bf85e9a7c509995622824d6db106f22b91b81e7e5bd8893f22f6511441ba1e8c"
        )
    ]
)
