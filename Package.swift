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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.21.1/Netomi.xcframework.zip",
            checksum: "64181cfd52cb95d27661e85e8ea2f5fdf0a253cb4433206874560a8643cd0e3d"
        )
    ]
)
