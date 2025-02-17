import Pgvector
import PostgresNIO

public enum PgvectorError: Error {
    case string(String)
}

public struct PgvectorNIO {
    // note: global OID for each type is not ideal since it will be different for each database
    public static func registerTypes(_ client: PostgresClient) async throws {
        let rows = try await client.query("SELECT regtype('vector')::oid::integer, regtype('halfvec')::oid::integer, regtype('sparsevec')::oid::integer")

        var iterator = rows.makeAsyncIterator()
        guard let row = try await iterator.next() else {
            throw PgvectorError.string("unreachable")
        }
        let (vectorOid, halfvecOid, sparsevecOid) = try row.decode((Int?, Int?, Int?).self)

        if let oid = vectorOid {
            Vector.psqlType = PostgresDataType(UInt32(oid))
        } else {
            throw PgvectorError.string("vector type not found in the database")
        }

        if let oid = halfvecOid {
            HalfVector.psqlType = PostgresDataType(UInt32(oid))
        }

        if let oid = sparsevecOid {
            SparseVector.psqlType = PostgresDataType(UInt32(oid))
        }
    }
}
