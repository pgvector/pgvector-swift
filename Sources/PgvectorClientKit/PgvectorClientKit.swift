import Pgvector
import PostgresClientKit

extension Vector: @retroactive PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: value))
    }
}

extension HalfVector: @retroactive PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: value))
    }
}
