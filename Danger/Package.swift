// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dangerfile",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "DangerDepsProduct",
            type: .dynamic,
            targets: ["DangerDependencies"]
        ),
    ],
    dependencies: [
        // Danger
        .package(name: "danger-swift", url: "https://github.com/danger/swift.git", from: "3.0.0"),
        // Danger Plugins
        .package(name: "DangerSwiftKantoku", url: "https://github.com/yumemi-inc/danger-swift-kantoku.git", from: "0.1.0"),
        .package(name: "DangerSwiftCoverage", url: "https://github.com/f-meloni/danger-swift-coverage.git", from: "1.2.0"),
        .package(name: "DangerSwiftHammer", url: "https://github.com/el-hoshino/DangerSwiftHammer.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "DangerDependencies",
            dependencies: [
                .product(name: "Danger", package: "danger-swift"),
                "DangerSwiftKantoku",
                "DangerSwiftCoverage",
                "DangerSwiftHammer",
            ]
        ),
    ]
)