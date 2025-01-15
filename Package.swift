// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Global",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "Global",
            targets: ["Global"]),
        .library(
            name: "GlobalMacros",
            targets: ["GlobalMacros"]
        ),
        .executable(
            name: "GlobalMacroClient",
            targets: ["GlobalMacroClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest")
    ],
    targets: [
        .target(
            name: "Global"
        ),
        .macro(
            name: "GlobalMacroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "GlobalMacros",
            dependencies: ["GlobalMacroMacros", "Global"]
        ),
        .executableTarget(
            name: "GlobalMacroClient",
            dependencies: ["GlobalMacros", "Global"]
        ),
        .testTarget(
            name: "GlobalMacroTests",
            dependencies: [
                "GlobalMacroMacros",
                "GlobalMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "GlobalTests",
            dependencies: ["Global"]
        )
    ]
)
