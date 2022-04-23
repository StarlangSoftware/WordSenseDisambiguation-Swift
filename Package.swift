// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WordSenseDisambiguation",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "WordSenseDisambiguation",
            targets: ["WordSenseDisambiguation"]),
    ],
    dependencies: [
        .package(name: "AnnotatedTree", url: "https://github.com/StarlangSoftware/AnnotatedTree-Swift.git", .exact("1.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "WordSenseDisambiguation",
            dependencies: ["AnnotatedTree"]),
        .testTarget(
            name: "WordSenseDisambiguationTests",
            dependencies: ["WordSenseDisambiguation"]),
    ]
)
