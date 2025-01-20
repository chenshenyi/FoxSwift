// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FoxSwiftAPI",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    targets: [
        .target(
            name: "FoxSwiftAPI",
            dependencies: [.byName(name: "APICore")],
            swiftSettings: swiftSettings
        ),
        .target(
            name: "APICore",
            swiftSettings: swiftSettings
        ),
    ]
)

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]
