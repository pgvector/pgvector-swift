import Pgvector
import PostgresNIO

extension SparseVector: @retroactive PostgresEncodable {
    public static var psqlType: PostgresDataType = PostgresDataType(1)

    public static var psqlFormat: PostgresFormat {
        .binary
    }

    public func encode<JSONEncoder: PostgresJSONEncoder>(
        into byteBuffer: inout ByteBuffer,
        context: PostgresEncodingContext<JSONEncoder>
    ) {
        byteBuffer.writeInteger(Int32(dim), as: Int32.self)
        byteBuffer.writeInteger(Int32(indices.count), as: Int32.self)
        byteBuffer.writeInteger(0, as: Int32.self)
        for v in indices {
            byteBuffer.writeInteger(Int32(v), as: Int32.self)
        }
        for v in values {
            byteBuffer.writeInteger(v.bitPattern, as: UInt32.self)
        }
    }
}

extension SparseVector: @retroactive PostgresDecodable {
    public init<JSONDecoder: PostgresJSONDecoder>(
        from buffer: inout ByteBuffer,
        type: PostgresDataType,
        format: PostgresFormat,
        context: PostgresDecodingContext<JSONDecoder>
    ) throws {
        guard type.isUserDefined else {
            throw PostgresDecodingError.Code.typeMismatch
        }

        guard format == .binary else {
            throw PostgresDecodingError.Code.failure;
        }

        guard buffer.readableBytes >= 4, let dim = buffer.readInteger(as: Int32.self) else {
            throw PostgresDecodingError.Code.failure
        }

        guard buffer.readableBytes >= 4, let nnz = buffer.readInteger(as: Int32.self) else {
            throw PostgresDecodingError.Code.failure
        }

        guard buffer.readableBytes >= 4, let unused = buffer.readInteger(as: Int32.self), unused == 0 else {
            throw PostgresDecodingError.Code.failure
        }

        var indices: [Int] = []
        for _ in 0..<nnz {
            guard buffer.readableBytes >= 4, let v = buffer.readInteger(as: Int32.self) else {
                throw PostgresDecodingError.Code.failure
            }
            indices.append(Int(v))
        }

        var values: [Float] = []
        for _ in 0..<nnz {
            guard buffer.readableBytes >= 4, let v = buffer.readInteger(as: UInt32.self) else {
                throw PostgresDecodingError.Code.failure
            }
            values.append(Float(bitPattern: v))
        }

        self.init(dim: Int(dim), indices: indices, values: values)!
    }
}
