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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.2.1/Netomi.xcframework.zip",
            checksum: "762d4e67a28b0d7c73367b1ee7b2d59bdc313749a160ec715e5ce849539221b0"
        )
    ]
)
