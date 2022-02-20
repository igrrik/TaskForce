// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TaskForceCore",
    platforms: [.iOS(.v14), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TaskForceCore",
            targets: ["TaskForceCore"]
        )
    ],
    dependencies: [
        .package(
            name: "CombineExt",
            url: "https://github.com/CombineCommunity/CombineExt.git",
            .upToNextMajor(from: "1.5.1")
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TaskForceCore",
            dependencies: ["CombineExt"],
            path: "Sources"
        ),
        .testTarget(
            name: "TaskForceCoreTests",
            dependencies: ["TaskForceCore"],
            path: "Tests"
        )
    ]
)
