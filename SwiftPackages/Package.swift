// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dependencies",
    products: [],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.51.0"),
    ],
    targets: []
)
