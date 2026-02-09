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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.18.0/Netomi.xcframework.zip",
            checksum: "e6c1bf52561b34fe086e7b0aaa0a6164670de703262dd97b15fa234aeb01aa24"
        )
    ]
)
