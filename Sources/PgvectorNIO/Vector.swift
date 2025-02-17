import Pgvector
import PostgresNIO

extension Vector: @retroactive PostgresEncodable {
    public static var psqlType: PostgresDataType = PostgresDataType(1)

    public static var psqlFormat: PostgresFormat {
        .binary
    }

    public func encode<JSONEncoder: PostgresJSONEncoder>(
        into byteBuffer: inout ByteBuffer,
        context: PostgresEncodingContext<JSONEncoder>
    ) {
        byteBuffer.writeInteger(Int16(value.count), as: Int16.self)
        byteBuffer.writeInteger(0, as: Int16.self)
        for v in value {
            byteBuffer.writeInteger(v.bitPattern)
        }
    }
}

extension Vector: @retroactive PostgresDecodable {
    public init<JSONDecoder: PostgresJSONDecoder>(
        from buffer: inout ByteBuffer,
        type: PostgresDataType,
        format: PostgresFormat,
        context: PostgresDecodingContext<JSONDecoder>
    ) throws {
        guard type == Vector.psqlType, type.isUserDefined else {
            throw PostgresDecodingError.Code.typeMismatch
        }

        guard format == .binary else {
            throw PostgresDecodingError.Code.failure;
        }

        guard buffer.readableBytes >= 2, let dim = buffer.readInteger(as: Int16.self) else {
            throw PostgresDecodingError.Code.failure
        }

        guard buffer.readableBytes >= 2, let unused = buffer.readInteger(as: Int16.self), unused == 0 else {
            throw PostgresDecodingError.Code.failure
        }

        var value: [Float] = []
        for _ in 0..<dim {
            guard buffer.readableBytes >= 4, let v = buffer.readInteger(as: UInt32.self) else {
                throw PostgresDecodingError.Code.failure
            }
            value.append(Float(bitPattern: v))
        }
        self.init(value)
    }
}
