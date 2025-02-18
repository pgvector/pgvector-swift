// swift-tools-version: 5.7

import Foundation
import PackageDescription

var package = Package(
    name: "Pgvector",
    products: [
        .library(
            name: "Pgvector",
            targets: ["Pgvector"]),
        .library(
            name: "PgvectorClientKit",
            targets: ["PgvectorClientKit"]),
        .library(
            name: "PgvectorNIO",
            targets: ["PgvectorNIO"]),
    ],
    dependencies: [
        .package(url: "https://github.com/codewinsdotcom/PostgresClientKit", from: "1.0.0"),
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Pgvector",
            dependencies: []),
        .target(
            name: "PgvectorClientKit",
            dependencies: [
                "Pgvector",
                "PostgresClientKit"
            ]),
        .target(
            name: "PgvectorNIO",
            dependencies: [
                "Pgvector",
                .product(name: "PostgresNIO", package: "postgres-nio")
            ]),
        .testTarget(
            name: "PgvectorTests",
            dependencies: [
                "Pgvector",
                "PgvectorClientKit",
                "PgvectorNIO",
                "PostgresClientKit",
                .product(name: "PostgresNIO", package: "postgres-nio")
            ]),
    ]
)

if ProcessInfo.processInfo.environment["TEST"] != nil {
    package.platforms = [.macOS(.v13)]
}
