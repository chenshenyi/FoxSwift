// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private extension String {
    static let testableFatal = "TestableFatal"

    var test: String {
        self + "Test"
    }
}

let package = Package(
    name: "test-util",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: .testableFatal,
            targets: [
                .testableFatal,
            ]
        )
    ],
    targets: [
        .target(
            name: .testableFatal,
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: .testableFatal.test,
            dependencies: [
                .target(name: .testableFatal)
            ],
            swiftSettings: swiftSettings
        )
    ]
)

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]

