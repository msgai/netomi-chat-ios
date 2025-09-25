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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.8.0/Netomi.xcframework.zip",
            checksum: "5a0ce0cfd42a97989832458e38d733059564225f5a842105e16b4e6e5e2e90e4"
        )
    ]
)
