// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Example",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/mattt/ollama-swift", from: "1.2.0"),
        .package(url: "https://github.com/vapor/postgres-nio", from: "1.24.0"),
        .package(url: "https://github.com/pgvector/pgvector-swift", from: "0.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "Example",
            dependencies: [
                .product(name: "Ollama", package: "ollama-swift"),
                .product(name: "PostgresNIO", package: "postgres-nio"),
                .product(name: "Pgvector", package: "pgvector-swift"),
                .product(name: "PgvectorNIO", package: "pgvector-swift"),
            ])
    ]
)
