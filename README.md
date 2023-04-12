# pgvector-swift

[pgvector](https://github.com/pgvector/pgvector) examples for Swift

Supports [PostgresClientKit](https://github.com/codewinsdotcom/PostgresClientKit)

[![Build Status](https://github.com/pgvector/pgvector-swift/workflows/build/badge.svg?branch=master)](https://github.com/pgvector/pgvector-swift/actions)

## Getting Started

Follow the instructions for your database library:

- [PostgresClientKit](#postgresclientkit)

## PostgresClientKit

Create a table

```swift
let text = "CREATE TABLE items (id bigserial primary key, embedding vector(3))"
let statement = try connection.prepareStatement(text: text)
try statement.execute()
```

Insert vectors

```swift
let text = "INSERT INTO items (embedding) VALUES ($1), ($2), ($3)"
let statement = try connection.prepareStatement(text: text)
try statement.execute(parameterValues: [ "[1,1,1]", "[2,2,2]", "[1,1,2]" ])
```

Get the nearest neighbors

```swift
let text = "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5"
let statement = try connection.prepareStatement(text: text)
let cursor = try statement.execute(parameterValues: [ "[1,1,1]" ])

for row in cursor {
    let columns = try row.get().columns
    let id = try columns[0].int()
    let embedding = try columns[1].string()
    print(id, embedding)
}
```

See a [full example](Tests/PgvectorTests/PgvectorTests.swift)

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
