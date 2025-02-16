# pgvector-swift

[pgvector](https://github.com/pgvector/pgvector) examples for Swift

Supports [PostgresNIO](https://github.com/vapor/postgres-nio) and [PostgresClientKit](https://github.com/codewinsdotcom/PostgresClientKit)

[![Build Status](https://github.com/pgvector/pgvector-swift/actions/workflows/build.yml/badge.svg)](https://github.com/pgvector/pgvector-swift/actions)

## Getting Started

Follow the instructions for your database library:

- [PostgresNIO](#postgresnio)
- [PostgresClientKit](#postgresclientkit)

Or check out an example:

- [Embeddings](Examples/Ollama/Sources/main.swift) with Ollama

## PostgresNIO

Enable the extension

```swift
try await client.query("CREATE EXTENSION IF NOT EXISTS vector")
```

Create a table

```swift
try await client.query("CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")
```

Insert vectors

```swift
let embedding1 = "[1,1,1]"
let embedding2 = "[2,2,2]"
let embedding3 = "[1,1,2]"
try await client.query("INSERT INTO items (embedding) VALUES (\(embedding1)::vector), (\(embedding2)::vector), (\(embedding3)::vector)")
```

Get the nearest neighbors

```swift
let embedding = "[1,1,1]"
let rows = try await client.query("SELECT id, embedding::text FROM items ORDER BY embedding <-> \(embedding)::vector LIMIT 5")
for try await row in rows {
    print(row)
}
```

Add an approximate index

```swift
try await client.query("CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
// or
try await client.query("CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)")
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](Tests/PgvectorTests/PostgresNIOTests.swift)

## PostgresClientKit

Enable the extension

```swift
let text = "CREATE EXTENSION IF NOT EXISTS vector"
let statement = try connection.prepareStatement(text: text)
try statement.execute()
```

Create a table

```swift
let text = "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))"
let statement = try connection.prepareStatement(text: text)
try statement.execute()
```

Insert vectors

```swift
let text = "INSERT INTO items (embedding) VALUES ($1), ($2), ($3)"
let statement = try connection.prepareStatement(text: text)
try statement.execute(parameterValues: ["[1,1,1]", "[2,2,2]", "[1,1,2]"])
```

Get the nearest neighbors

```swift
let text = "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5"
let statement = try connection.prepareStatement(text: text)
let cursor = try statement.execute(parameterValues: ["[1,1,1]"])

for row in cursor {
    let columns = try row.get().columns
    let id = try columns[0].int()
    let embedding = try columns[1].string()
    print(id, embedding)
}
```

Add an approximate index

```swift
let text = "CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)"
// or
let text = "CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)"
let statement = try connection.prepareStatement(text: text)
try statement.execute()
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](Tests/PgvectorTests/PostgresClientKitTests.swift)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/pgvector/pgvector-swift/issues)
- Fix bugs and [submit pull requests](https://github.com/pgvector/pgvector-swift/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/pgvector/pgvector-swift.git
cd pgvector-swift
createdb pgvector_swift_test
swift test
```

To run an example:

```sh
cd Examples/Ollama
createdb pgvector_example
swift run
```
