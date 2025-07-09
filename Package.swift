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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.2.0/Netomi.xcframework.zip",
            checksum: "41a0973452b68976bb056bda038f1997acd7b6ca6ecbd3480dd44a65d0da6e4d"
        )
    ]
)
 
