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
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/joshuawright11/papyrus.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: .foxSwiftAPI,
            dependencies: [
                .product(name: "Papyrus", package: "papyrus")
            ],
            swiftSettings: swiftSettings
        )
    ]
)

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]
