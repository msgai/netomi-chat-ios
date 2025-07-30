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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.4.1/Netomi.xcframework.zip",
            checksum: "053ab86a87f884bdebbf3c2a89c7a4768e8eeb587bc0023a1d868adb77b6b55e"
        )
    ]
)
