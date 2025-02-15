import Testing
import Foundation
import PostgresClientKit
import PostgresNIO
import NIOPosix
import Logging
@testable import Pgvector

final class PgvectorTests {
    @Test func postgresClientKit() throws {
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.database = "pgvector_swift_test"
        configuration.ssl = false
        configuration.user = ProcessInfo.processInfo.environment["USER"]!

        let connection = try PostgresClientKit.Connection(configuration: configuration)
        defer { connection.close() }

        var text = "CREATE EXTENSION IF NOT EXISTS vector"
        var statement = try connection.prepareStatement(text: text)
        try statement.execute()

        text = "DROP TABLE IF EXISTS items"
        statement = try connection.prepareStatement(text: text)
        try statement.execute()

        text = "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))"
        statement = try connection.prepareStatement(text: text)
        try statement.execute()

        text = "INSERT INTO items (embedding) VALUES ($1), ($2), ($3)"
        statement = try connection.prepareStatement(text: text)
        try statement.execute(parameterValues: [ "[1,1,1]", "[2,2,2]", "[1,1,2]" ])

        text = "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5"
        statement = try connection.prepareStatement(text: text)
        let cursor = try statement.execute(parameterValues: [ "[1,1,1]" ])

        for row in cursor {
            let columns = try row.get().columns
            let id = try columns[0].int()
            let embedding = try columns[1].string()
            print(id, embedding)
        }

        text = "CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 1)"
        statement = try connection.prepareStatement(text: text)
        try statement.execute()
    }

    @Test func postgresNIO() async throws {
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        let logger = Logger(label: "postgres-logger")

        let config = PostgresConnection.Configuration(
            host: "localhost",
            port: 5432,
            username: ProcessInfo.processInfo.environment["USER"]!,
            password: nil,
            database: "pgvector_swift_test",
            tls: .disable
        )

        let connection = try await PostgresConnection.connect(
            on: eventLoopGroup.next(),
            configuration: config,
            id: 1,
            logger: logger
        )

        try await connection.query("CREATE EXTENSION IF NOT EXISTS vector", logger: logger)
        try await connection.query("DROP TABLE IF EXISTS nio_items", logger: logger)
        try await connection.query("CREATE TABLE nio_items (id bigserial PRIMARY KEY, embedding vector(3))", logger: logger)

        let embedding1 = "[1,1,1]"
        let embedding2 = "[2,2,2]"
        let embedding3 = "[1,1,2]"
        try await connection.query("INSERT INTO nio_items (embedding) VALUES (\(embedding1)::vector), (\(embedding2)::vector), (\(embedding3)::vector)", logger: logger)

        let embedding = "[1,1,1]"
        let rows = try await connection.query("SELECT id, embedding::text FROM nio_items ORDER BY embedding <-> \(embedding)::vector LIMIT 5", logger: logger)
        for try await row in rows {
            print(row)
        }

        try await connection.query("CREATE INDEX ON nio_items USING ivfflat (embedding vector_l2_ops) WITH (lists = 1)", logger: logger)

        try await connection.close()
    }
}
