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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.18.4/Netomi.xcframework.zip",
            checksum: "7d4dca7e88e1f52c1d61ca817ebc12cc757fd2adf2a8a53519291cea653a623c"
        )
    ]
)
