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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.1.10/Netomi.xcframework.zip",
            checksum: "78a3348dfec106dce2102f961c9b9a0f81d28855c1ac3ed0f11970d5a7d65cb5"
        )
    ]
)
