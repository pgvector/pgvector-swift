// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Pgvector",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "Pgvector",
            targets: ["Pgvector"]),
    ],
    dependencies: [
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit", from: "1.5.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.24.0"),
    ],
    targets: [
        .target(
            name: "Pgvector",
            dependencies: []),
        .testTarget(
            name: "PgvectorTests",
            dependencies: [
                "Pgvector",
                "PostgresClientKit",
                .product(name: "PostgresNIO", package: "postgres-nio")
            ]),
    ]
)
