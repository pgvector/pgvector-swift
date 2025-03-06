import Foundation
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

struct ApiData: Encodable {
    var model: String
    var input: [String]
}

struct ApiResponse: Decodable {
    var embeddings: [[Float]]
}

func embed(input: [String], taskType: String) async throws -> [[Float]] {
    // nomic-embed-text uses a task prefix
    // https://huggingface.co/nomic-ai/nomic-embed-text-v1.5
    let input = input.map { taskType + ": " + $0 }

    let url = URL(string: "http://localhost:11434/api/embed")!
    let data = ApiData(
        model: "nomic-embed-text",
        input: input
    )

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(data)
    let (body, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(ApiResponse.self, from: body)

    return response.embeddings
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
    let embeddings = try await embed(input: input, taskType: "search_document")
    for (content, embedding) in zip(input, embeddings) {
        let embedding = Vector(embedding)
        try await client.query("INSERT INTO documents (content, embedding) VALUES (\(content), \(embedding))")
    }

    let query = "forest"
    let embedding = Vector((try await embed(input: [query], taskType: "search_query"))[0])
    let rows = try await client.query("SELECT content FROM documents ORDER BY embedding <=> \(embedding) LIMIT 5")
    for try await row in rows {
        print(row)
    }

    taskGroup.cancelAll()
}
