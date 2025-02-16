import Foundation
import Ollama
import PostgresNIO

let config = PostgresClient.Configuration(
    host: "localhost",
    port: 5432,
    username: ProcessInfo.processInfo.environment["USER"]!,
    password: nil,
    database: "pgvector_example",
    tls: .disable
)

let client = PostgresClient(configuration: config)

func generateEmbedding(input: String) async throws -> [Double] {
    let response = try await Client.default.embed(
        model: "nomic-embed-text",
        input: input
    )
    return response.embeddings.rawValue[0]
}

try await withThrowingTaskGroup(of: Void.self) { taskGroup in
    taskGroup.addTask {
        await client.run()
    }

    try await client.query("CREATE EXTENSION IF NOT EXISTS vector")
    try await client.query("DROP TABLE IF EXISTS documents")
    try await client.query("CREATE TABLE documents (id serial PRIMARY KEY, content text, embedding vector(768))")

    let input = [
        "The dog is barking",
        "The cat is purring",
        "The bear is growling",
    ]

    for content in input {
        let embedding = try await generateEmbedding(input: content)
        try await client.query("INSERT INTO documents (content, embedding) VALUES (\(content), \(embedding))")
    }

    let query = "forest"
    let embedding = try await generateEmbedding(input: query)
    let rows = try await client.query("SELECT content FROM documents ORDER BY embedding <=> \(embedding)::vector LIMIT 5")
    for try await row in rows {
        print(row)
    }

    taskGroup.cancelAll()
}
