// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.24.0")
    ],
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: [
                .product(name: "PostgresNIO", package: "postgres-nio")
            ])
    ]
)
