import Pgvector
import PostgresClientKit

extension Vector: @retroactive PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(text())
    }
}

public extension PostgresValue {
    func vector() throws -> Vector {
        if isNull {
            throw PostgresError.valueIsNil
        }
        return try optionalVector()!
    }

    func optionalVector() throws -> Vector? {
        guard let rawValue = rawValue else { return nil }

        guard let vector = Vector(rawValue) else {
            throw PostgresError.valueConversionError(value: self, type: Vector.self)
        }

        return vector
    }
}
