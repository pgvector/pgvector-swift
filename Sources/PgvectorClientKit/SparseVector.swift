import Pgvector
import PostgresClientKit

extension SparseVector: @retroactive PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(text())
    }
}

public extension PostgresValue {
    func sparseVector() throws -> SparseVector {
        if isNull {
            throw PostgresError.valueIsNil
        }
        return try optionalSparseVector()!
    }

    func optionalSparseVector() throws -> SparseVector? {
        guard let rawValue = rawValue else { return nil }

        guard let vector = SparseVector(rawValue) else {
            throw PostgresError.valueConversionError(value: self, type: SparseVector.self)
        }

        return vector
    }
}
