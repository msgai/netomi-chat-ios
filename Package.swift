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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.20.0/Netomi.xcframework.zip",
            checksum: "f8f9571968b9e045b49ae3fab8847eb31ac77b29ffb43741d8649290ddd39646"
        )
    ]
)
