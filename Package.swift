// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SupportKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NavigationKit",
            targets: ["NavigationKit"]),
        .library(
            name: "TaskKit",
            targets: ["TaskKit"]),
        .library(
            name: "WebAPIKit",
            targets: ["WebAPIKit"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NavigationKit"),
        .target(
            name: "TaskKit"),
        .target(
            name: "WebAPIKit",
            dependencies: ["TaskKit"]),
        .testTarget(
            name: "TaskKitTests",
            dependencies: ["TaskKit"]),
        .testTarget(
            name: "WebAPIKitTests",
            dependencies: ["WebAPIKit"])
    ]
)
