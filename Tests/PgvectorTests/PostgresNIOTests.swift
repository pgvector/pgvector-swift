import Foundation
import PostgresNIO
import Testing
@testable import Pgvector

final class PostgresNIOTests {
    @Test func example() async throws {
        let config = PostgresClient.Configuration(
            host: "localhost",
            port: 5432,
            username: ProcessInfo.processInfo.environment["USER"]!,
            password: nil,
            database: "pgvector_swift_test",
            tls: .disable
        )

        let client = PostgresClient(configuration: config)

        try await withThrowingTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                await client.run()
            }

            try await client.query("CREATE EXTENSION IF NOT EXISTS vector")
            try await client.query("DROP TABLE IF EXISTS nio_items")
            try await client.query("CREATE TABLE nio_items (id bigserial PRIMARY KEY, embedding vector(3))")

            let embedding1 = "[1,1,1]"
            let embedding2 = "[2,2,2]"
            let embedding3 = "[1,1,2]"
            try await client.query("INSERT INTO nio_items (embedding) VALUES (\(embedding1)::vector), (\(embedding2)::vector), (\(embedding3)::vector)")

            let embedding = "[1,1,1]"
            let rows = try await client.query("SELECT id, embedding::text FROM nio_items ORDER BY embedding <-> \(embedding)::vector LIMIT 5")
            for try await row in rows {
                print(row)
            }

            try await client.query("CREATE INDEX ON nio_items USING hnsw (embedding vector_l2_ops)")

            taskGroup.cancelAll()
        }
    }
}
