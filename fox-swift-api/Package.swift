// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

extension String {
    // dependencies
    static let util = "util"

    // targets
    static let foxSwiftAPI = "FoxSwiftAPI"
    static let apiPlugin = "APIPlugin"
    static let apiCore = "APICore"

    var test: String {
        self + "Test"
    }
}

let package = Package(
    name: "fox-swift-api",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: .foxSwiftAPI,
            targets: [
                .foxSwiftAPI,
                .apiCore
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", from: "510.0.0"),
        .package(url: "https://github.com/joshuawright11/papyrus.git", from: "0.6.0"),
        .package(url: "https://github.com/vapor/routing-kit.git", from: "4.9.0"),

        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),
    ],
    targets: [
        .target(
            name: .foxSwiftAPI,
            dependencies: [
                .product(name: "Papyrus", package: "papyrus"),
                .product(name: "Vapor", package: "vapor"),
                .byName(name: .apiCore)
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: .apiCore,
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "RoutingKit", package: "routing-kit"),
                .byName(name: .apiPlugin)
            ]
        ),
        .macro(
            name: .apiPlugin,
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: .apiPlugin.test,
            dependencies: [
                .target(name: .apiPlugin)
            ]
        ),
        .testTarget(
            name: .foxSwiftAPI.test,
            dependencies: [
                .target(name: .foxSwiftAPI)
            ]
        )
    ]
)

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]
