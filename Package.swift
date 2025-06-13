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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.1.7/Netomi.xcframework.zip",
            checksum: "b1e23c8a0b3165cb68f0d8d0634936cf87bf76846d535eba45cc98e184792568"
        )
    ]
)
