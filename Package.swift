// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetomiChatSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NetomiChatSDK",
            targets: ["Netomi"]),
    ],
    targets: [
            .binaryTarget(
                name: "Netomi",
                url: "https://github.com/msgai/netomi-chat-ios/releases/download/v2.1.0/Netomi.xcframework.zip",
                checksum: "c0ffeec0ffeec0ffeec0ffeec0ffeec0ffeec0ffeec0ffeec0ffeec0ffeec0ff"
            )
        ]

)
