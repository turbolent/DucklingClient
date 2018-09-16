// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "DucklingClient",
    products: [
        .library(
            name: "DucklingClient",
            targets: ["DucklingClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result.git", .exact("4.0.0")),
    ],
    targets: [
        .target(
            name: "DucklingClient",
            dependencies: ["Result"]),
        .testTarget(
            name: "DucklingClientTests",
            dependencies: ["DucklingClient"]),
    ]
)
