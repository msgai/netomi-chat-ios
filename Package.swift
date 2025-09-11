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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.6.1/Netomi.xcframework.zip",
            checksum: "3944fb78f236f199c0aa6523374a9cb699b300ac2f7200f5b04cd8fa50a3e894"
        )
    ]
)
