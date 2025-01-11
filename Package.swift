// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Global",
    products: [
        .library(
            name: "Global",
            targets: ["Global"]),
    ],
    targets: [
        .target(
            name: "Global"),
    ]
)
