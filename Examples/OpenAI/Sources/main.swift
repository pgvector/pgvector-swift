import Foundation
import Pgvector
import PgvectorNIO
import PostgresNIO

guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
    print("Set OPENAI_API_KEY")
    exit(1)
}

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
    var data: [ApiObject]
}

struct ApiObject: Decodable {
    var embedding: [Float]
}

func embed(input: [String], apiKey: String) async throws -> [[Float]] {
    let url = URL(string: "https://api.openai.com/v1/embeddings")!
    let data = ApiData(
        model: "text-embedding-3-small",
        input: input
    )

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(data)
    let (body, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(ApiResponse.self, from: body)

    return response.data.map { $0.embedding }
}

try await withThrowingTaskGroup(of: Void.self) { taskGroup in
    taskGroup.addTask {
        await client.run()
    }

    try await client.query("CREATE EXTENSION IF NOT EXISTS vector")
    try await PgvectorNIO.registerTypes(client)

    try await client.query("DROP TABLE IF EXISTS documents")
    try await client.query("CREATE TABLE documents (id serial PRIMARY KEY, content text, embedding vector(1536))")

    let input = [
        "The dog is barking",
        "The cat is purring",
        "The bear is growling",
    ]
    let embeddings = try await embed(input: input, apiKey: apiKey)
    for (content, embedding) in zip(input, embeddings) {
        let embedding = Vector(embedding)
        try await client.query("INSERT INTO documents (content, embedding) VALUES (\(content), \(embedding))")
    }

    let query = "forest"
    let queryEmbedding = Vector((try await embed(input: [query], apiKey: apiKey))[0])
    let rows = try await client.query("SELECT content FROM documents ORDER BY embedding <=> \(queryEmbedding) LIMIT 5")
    for try await row in rows {
        print(row)
    }

    taskGroup.cancelAll()
}
