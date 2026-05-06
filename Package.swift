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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.22.0/Netomi.xcframework.zip",
            checksum: "04dbf771ba46b2648fb02ca34968e66a2d4b3f5299f019d6f07d40d66d047f77"
        )
    ]
)
