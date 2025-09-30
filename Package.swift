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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.9.0/Netomi.xcframework.zip",
            checksum: "7cb3761d24c66278b814b0afe9165596966dc0161d56c716f8fe69e8775b3657"
        )
    ]
)
