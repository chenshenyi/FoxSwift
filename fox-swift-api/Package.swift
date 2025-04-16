// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

extension String {
    // targets
    static let foxSwiftAPI = "FoxSwiftAPI"
    static let apiPlugin = "APIPlugin"
    static let apiCore = "APICore"
    static let tests = "Tests"
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
                .apiCore,
            ]
        )
    ],
    dependencies: [
        // 🍎 A collection of Swift tools for parsing, inspecting, and transforming Swift source code.
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "509.0.0"),

        // 🛠️ A convenient utility for building RESTful APIs with macros.
        .package(url: "https://github.com/joshuawright11/papyrus.git", from: "0.6.0"),

        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.110.1"),

        // 🩺 A testing framework for Swift macros.
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.1.0"),

        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.3"),
    ],
    targets: [
        .target(
            name: .foxSwiftAPI,
            dependencies: [
                .product(name: "Papyrus", package: "papyrus"),
                .product(name: "Vapor", package: "vapor"),
                .byName(name: .apiCore),
            ],
            swiftSettings: swiftSettings,
        ),
        .target(
            name: .apiCore,
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "VaporTesting", package: "vapor"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .byName(name: .apiPlugin),
            ],
        ),
        .macro(
            name: .apiPlugin,
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftOperators", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftParserDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
        ),
        .testTarget(
            name: .foxSwiftAPI + "Test",
            dependencies: [
                .target(name: .apiPlugin),
                .target(name: .foxSwiftAPI),
                .target(name: .apiCore),
                .product(name: "VaporTesting", package: "vapor"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ],
            path: .tests,
        ),
    ]
)

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]
