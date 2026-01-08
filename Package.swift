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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.16.3/Netomi.xcframework.zip",
            checksum: "eb8e08779f728ca5c04ccb90b1193414cdd43983477e7195d9b88ccbb88f9798"
        )
    ]
)
