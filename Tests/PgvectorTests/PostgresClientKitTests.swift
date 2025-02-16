import Testing
import Foundation
import PostgresClientKit
@testable import Pgvector

final class PostgresClientKitTests {
    @Test func example() throws {
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.database = "pgvector_swift_test"
        configuration.ssl = false
        configuration.user = ProcessInfo.processInfo.environment["USER"]!

        let connection = try PostgresClientKit.Connection(configuration: configuration)
        defer { connection.close() }

        var text = "CREATE EXTENSION IF NOT EXISTS vector"
        var statement = try connection.prepareStatement(text: text)
        try statement.execute()

        text = "DROP TABLE IF EXISTS items"
        statement = try connection.prepareStatement(text: text)
        try statement.execute()

        text = "CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))"
        statement = try connection.prepareStatement(text: text)
        try statement.execute()

        text = "INSERT INTO items (embedding) VALUES ($1), ($2), ($3)"
        statement = try connection.prepareStatement(text: text)
        try statement.execute(parameterValues: [ "[1,1,1]", "[2,2,2]", "[1,1,2]" ])

        text = "SELECT * FROM items ORDER BY embedding <-> $1 LIMIT 5"
        statement = try connection.prepareStatement(text: text)
        let cursor = try statement.execute(parameterValues: [ "[1,1,1]" ])

        for row in cursor {
            let columns = try row.get().columns
            let id = try columns[0].int()
            let embedding = try columns[1].string()
            print(id, embedding)
        }

        text = "CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 1)"
        statement = try connection.prepareStatement(text: text)
        try statement.execute()
    }
}
