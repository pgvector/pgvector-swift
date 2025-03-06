// good resources
// https://opensearch.org/blog/improving-document-retrieval-with-sparse-semantic-encoders/
// https://huggingface.co/opensearch-project/opensearch-neural-sparse-encoding-v1
//
// run with
// text-embeddings-router --model-id opensearch-project/opensearch-neural-sparse-encoding-v1 --pooling splade

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

struct ApiElement: Decodable {
    var index: Int
    var value: Float
}

func embed(input: [String]) async throws -> [[Int: Float]] {
    let url = URL(string: "http://localhost:3000/embed_sparse")!
    let data = [
        "inputs": input
    ]

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(data)
    let (body, _) = try await URLSession.shared.data(for: request)
    let response = try JSONDecoder().decode([[ApiElement]].self, from: body)

    return response.map { Dictionary(uniqueKeysWithValues: $0.map { ($0.index, $0.value) }) }
}

try await withThrowingTaskGroup(of: Void.self) { taskGroup in
    taskGroup.addTask {
        await client.run()
    }

    try await client.query("CREATE EXTENSION IF NOT EXISTS vector")
    try await PgvectorNIO.registerTypes(client)

    try await client.query("DROP TABLE IF EXISTS documents")
    try await client.query("CREATE TABLE documents (id serial PRIMARY KEY, content text, embedding sparsevec(30522))")

    let input = [
        "The dog is barking",
        "The cat is purring",
        "The bear is growling",
    ]
    let embeddings = try await embed(input: input)
    for (content, embedding) in zip(input, embeddings) {
        let embedding = SparseVector(embedding, dim: 30522)
        try await client.query("INSERT INTO documents (content, embedding) VALUES (\(content), \(embedding))")
    }

    let query = "forest"
    let embedding = SparseVector((try await embed(input: [query]))[0], dim: 30522)
    let rows = try await client.query("SELECT content FROM documents ORDER BY embedding <#> \(embedding) LIMIT 5")
    for try await row in rows {
        print(row)
    }

    taskGroup.cancelAll()
}
