import Foundation
import Logging
import PostgresNIO
import Testing

final class PostgresNIOTests {
    @Test func example() async throws {
        let config = PostgresConnection.Configuration(
            host: "localhost",
            port: 5432,
            username: ProcessInfo.processInfo.environment["USER"]!,
            password: nil,
            database: "pgvector_swift_test",
            tls: .disable
        )
        let logger = Logger(label: "postgres-logger")

        let connection = try await PostgresConnection.connect(
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
