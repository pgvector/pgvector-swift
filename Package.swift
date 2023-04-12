// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Pgvector",
    products: [
        .library(
            name: "Pgvector",
            targets: ["Pgvector"]),
    ],
    dependencies: [
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Pgvector",
            dependencies: []),
        .testTarget(
            name: "PgvectorTests",
            dependencies: ["Pgvector", "PostgresClientKit"]),
    ]
)
