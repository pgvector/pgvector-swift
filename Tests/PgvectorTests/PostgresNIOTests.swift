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
            try await PgvectorNIO.registerTypes(client)

            try await client.query("DROP TABLE IF EXISTS nio_items")
            try await client.query("CREATE TABLE nio_items (id bigserial PRIMARY KEY, embedding vector(3))")

            let embedding1 = Vector([1, 1, 1])
            let embedding2 = Vector([2, 2, 2])
            let embedding3 = Vector([1, 1, 2])
            try await client.query("INSERT INTO nio_items (embedding) VALUES (\(embedding1)), (\(embedding2)), (\(embedding3))")

            let embedding = Vector([1, 1, 1])
            let rows = try await client.query("SELECT id, embedding FROM nio_items ORDER BY embedding <-> \(embedding) LIMIT 5")
            for try await (id, embedding) in rows.decode((Int, Vector).self) {
                print(id, embedding)
            }

            try await client.query("CREATE INDEX ON nio_items USING hnsw (embedding vector_l2_ops)")

            let halfEmbedding = HalfVector([1, 2, 3])
            let sparseEmbedding = SparseVector([1, 0, 2, 0, 3, 0])
            let typeRows = try await client.query("SELECT \(embedding), \(halfEmbedding), \(sparseEmbedding)")
            for try await (v, h, s) in typeRows.decode((Vector, HalfVector, SparseVector).self) {
                print(v, h, s)
            }

            taskGroup.cancelAll()
        }
    }
}
