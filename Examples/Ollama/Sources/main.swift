import Foundation
import Ollama
import Pgvector
import PgvectorNIO
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

func embed(input: String, taskType: String) async throws -> [Float] {
    // nomic-embed-text uses a task prefix
    // https://huggingface.co/nomic-ai/nomic-embed-text-v1.5
    let input = taskType + ": " + input

    let response = try await Client.default.embed(
        model: "nomic-embed-text",
        input: input
    )
    return response.embeddings.rawValue[0].map { Float($0) }
}

try await withThrowingTaskGroup(of: Void.self) { taskGroup in
    taskGroup.addTask {
        await client.run()
    }

    try await client.query("CREATE EXTENSION IF NOT EXISTS vector")
    try await PgvectorNIO.registerTypes(client)

    try await client.query("DROP TABLE IF EXISTS documents")
    try await client.query("CREATE TABLE documents (id serial PRIMARY KEY, content text, embedding vector(768))")

    let input = [
        "The dog is barking",
        "The cat is purring",
        "The bear is growling",
    ]

    for content in input {
        let embedding = Vector(try await embed(input: content, taskType: "search_document"))
        try await client.query("INSERT INTO documents (content, embedding) VALUES (\(content), \(embedding))")
    }

    let query = "forest"
    let embedding = Vector(try await embed(input: query, taskType: "search_query"))
    let rows = try await client.query("SELECT content FROM documents ORDER BY embedding <=> \(embedding) LIMIT 5")
    for try await row in rows {
        print(row)
    }

    taskGroup.cancelAll()
}
