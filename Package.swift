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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.18.1/Netomi.xcframework.zip",
            checksum: "5bf23afa6801b1ede94ca0a0d7f0747a6404cf6ceb503cdbba17c55415b5d9e5"
        )
    ]
)
