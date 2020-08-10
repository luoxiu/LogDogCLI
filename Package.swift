// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogDogCLI",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .executable(name: "LogDogCLI", targets: ["LogDogCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.2.0"),
        .package(url: "https://github.com/luoxiu/LogDog.git", .branch("master")),
    ],
    targets: [
        .target(name: "LogDogCLI", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "LogDog",
        ]),
        .testTarget(name: "LogDogCLITests", dependencies: ["LogDogCLI"]),
    ]
)
