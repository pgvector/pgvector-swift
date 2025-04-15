import Foundation
import PostgresNIO

guard let apiKey = ProcessInfo.processInfo.environment["CO_API_KEY"] else {
    print("Set CO_API_KEY")
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
    var texts: [String]
    var model: String
    var inputType: String
    var embeddingTypes: [String]
}

struct EmbedResponse: Decodable {
    var embeddings: EmbeddingsObject
}

struct EmbeddingsObject: Decodable {
    var ubinary: [[UInt8]]
}

func embed(texts: [String], inputType: String, apiKey: String) async throws -> [String] {
    let url = URL(string: "https://api.cohere.com/v2/embed")!
    let data = ApiData(
        texts: texts,
        model: "embed-v4.0",
        inputType: inputType,
        embeddingTypes: ["ubinary"]
    )

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    request.httpBody = try encoder.encode(data)

    let (body, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode(EmbedResponse.self, from: body)

    return response.embeddings.ubinary.map {
        $0.map { String(repeating: "0", count: 8 - String($0, radix: 2).count) + String($0, radix: 2) }.joined()
    }
}

try await withThrowingTaskGroup(of: Void.self) { taskGroup in
    taskGroup.addTask {
        await client.run()
    }

    try await client.query("CREATE EXTENSION IF NOT EXISTS vector")
    try await client.query("DROP TABLE IF EXISTS documents")
    try await client.query("CREATE TABLE documents (id serial PRIMARY KEY, content text, embedding bit(1536))")

    let input = [
        "The dog is barking",
        "The cat is purring",
        "The bear is growling",
    ]
    let embeddings = try await embed(texts: input, inputType: "search_document", apiKey: apiKey)
    for (content, embedding) in zip(input, embeddings) {
        try await client.query("INSERT INTO documents (content, embedding) VALUES (\(content), \(embedding)::bit(1536))")
    }

    let query = "forest"
    let queryEmbedding = (try await embed(texts: [query], inputType: "search_query", apiKey: apiKey))[0]
    let rows = try await client.query("SELECT content FROM documents ORDER BY embedding <~> \(queryEmbedding)::bit(1536) LIMIT 5")
    for try await row in rows {
        print(row)
    }

    taskGroup.cancelAll()
}
