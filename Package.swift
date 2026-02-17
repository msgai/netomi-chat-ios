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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.18.2/Netomi.xcframework.zip",
            checksum: "ad4a883a8ed48ef4c2b3e1de3c5e7d0fad0f7d9f4903a8da365eec2b3920dc79"
        )
    ]
)
