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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.21.2/Netomi.xcframework.zip",
            checksum: "e3ca2e84d1b9603e852f242f1573c17e3ee88e810f0385e07534cec50ec4dde4"
        )
    ]
)
