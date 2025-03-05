import Pgvector
import PostgresClientKit

extension Vector: @retroactive PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(text())
    }
}

extension PostgresValue {
    public func vector() throws -> Vector {
        if isNull {
            throw PostgresError.valueIsNil
        }
        return try optionalVector()!
    }

    public func optionalVector() throws -> Vector? {
        guard let rawValue = rawValue else { return nil }

        guard let vector = Vector(rawValue) else {
            throw PostgresError.valueConversionError(value: self, type: Vector.self)
        }

        return vector
    }
}
