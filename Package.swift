// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Pgvector",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "Pgvector",
            targets: ["Pgvector"]),
        .library(
            name: "PgvectorClientKit",
            targets: ["PgvectorClientKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit", from: "1.5.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.24.0"),
    ],
    targets: [
        .target(
            name: "Pgvector",
            dependencies: []),
        .target(
            name: "PgvectorClientKit",
            dependencies: ["Pgvector", "PostgresClientKit"]),
        .testTarget(
            name: "PgvectorTests",
            dependencies: [
                "Pgvector",
                "PgvectorClientKit",
                "PostgresClientKit",
                .product(name: "PostgresNIO", package: "postgres-nio")
            ]),
    ]
)
