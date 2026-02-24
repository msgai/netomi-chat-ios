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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.18.3/Netomi.xcframework.zip",
            checksum: "e7c7f68210d70d448cc6925648b3265391f52d6dc1adefaa0a7c9bceace314cd"
        )
    ]
)
