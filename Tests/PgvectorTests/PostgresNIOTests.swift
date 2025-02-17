import Foundation
import Pgvector
import PgvectorNIO
import PostgresNIO
import Testing

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

            let embedding1 = Vector([1, 1, 1]).text()
            let embedding2 = Vector([2, 2, 2]).text()
            let embedding3 = Vector([1, 1, 2]).text()
            try await client.query("INSERT INTO nio_items (embedding) VALUES (\(embedding1)::vector), (\(embedding2)::vector), (\(embedding3)::vector)")

            let embedding = Vector([1, 1, 1]).text()
            let rows = try await client.query("SELECT id, embedding::text FROM nio_items ORDER BY embedding <-> \(embedding)::vector LIMIT 5")
            for try await (id, embedding) in rows.decode((Int, String).self) {
                print(id, Vector(embedding)!)
            }

            try await client.query("CREATE INDEX ON nio_items USING hnsw (embedding vector_l2_ops)")

            taskGroup.cancelAll()
        }
    }
}
