// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private extension String {
    static let commonUtil = "CommonUtil"
    static let concurrencyUtil = "ConcurrencyUtil"
    static let testUtil = "TestUtil"

    var test: String {
        self + "Test"
    }
}

let package = Package(
    name: "util",
    platforms: [
        .macOS(.v14),
        .iOS(.v16),
    ],
    products: [
        .library(
            name: .commonUtil,
            targets: [
                .commonUtil,
                .concurrencyUtil
            ]
        )
    ],
    targets: [
        .target(
            name: .commonUtil,
            swiftSettings: swiftSettings
        ),
        .target(
            name: .concurrencyUtil,
            dependencies: [
                .target(name: .commonUtil)
            ],
            swiftSettings: swiftSettings
        ),
        .target(
            name: .testUtil,
            dependencies: [
                .target(name: .commonUtil),
                .target(name: .concurrencyUtil)
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: .commonUtil.test,
            dependencies: [
                .target(name: .commonUtil)
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: .concurrencyUtil.test,
            dependencies: [
                .target(name: .concurrencyUtil)
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: .testUtil.test,
            dependencies: [
                .target(name: .testUtil)
            ],
            swiftSettings: swiftSettings
        )
    ]
)

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6)
]

