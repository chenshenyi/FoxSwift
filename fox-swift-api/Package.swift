// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    // dependencies
    static let util = "util"

    // targets
    static let foxSwiftAPI = "FoxSwiftAPI"
    static let apiCore = "APICore"
    
    // test targets
    static let apiCoreTest = "APICoreTest"
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
        .package(name: .util, path: .util)
    ],
    targets: [
        .target(
            name: .foxSwiftAPI,
            dependencies: [.byName(name: .apiCore)],
            swiftSettings: swiftSettings
        ),
        .target(
            name: .apiCore,
            dependencies: [
                .product(name: "CommonUtil", package: .util),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: .apiCoreTest,
            dependencies: [.byName(name: .apiCore)],
            swiftSettings: swiftSettings
        )
    ]
)

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]
