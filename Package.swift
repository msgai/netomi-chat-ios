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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.19.1/Netomi.xcframework.zip",
            checksum: "ef4e6621d7bc1822539be351c16d73f78aa3fa175bb94cfc10df92cdd244df83"
        )
    ]
)
