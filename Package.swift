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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.10.0/Netomi.xcframework.zip",
            checksum: "c65130e6624b9dc13503f8c2f24584cbcdc9bf26bf0f8b2c846432996371ac07"
        )
    ]
)
