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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.21.0/Netomi.xcframework.zip",
            checksum: "9239afddb49edc9579f47973b105d7ed4d51bf87556426bdee2a4ebaea3ccecc"
        )
    ]
)
