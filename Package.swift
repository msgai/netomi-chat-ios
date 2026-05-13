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
            url: "https://netomi-sdk-public.s3.amazonaws.com/sdk/ios/releases/1.23.0/Netomi.xcframework.zip",
            checksum: "3c671d4a692b3006b556070f6d75ad680e8ce732f8e3f567f0580ce97d55cc7b"
        )
    ]
)
