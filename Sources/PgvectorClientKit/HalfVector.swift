import Pgvector
import PostgresClientKit

extension HalfVector: @retroactive PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: value))
    }
}

public extension PostgresValue {
    func halfVector() throws -> HalfVector {
        if isNull {
            throw PostgresError.valueIsNil
        }
        return try optionalHalfVector()!
    }

    func optionalHalfVector() throws -> HalfVector? {
        guard let rawValue = rawValue else { return nil }

        guard let vector = HalfVector(rawValue) else {
            throw PostgresError.valueConversionError(value: self, type: HalfVector.self)
        }

        return vector
    }
}
