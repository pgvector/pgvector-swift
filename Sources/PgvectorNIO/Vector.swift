import Pgvector
import PostgresNIO

extension Vector: @retroactive PostgresDynamicTypeEncodable {
    public var psqlType: PostgresDataType {
        PostgresDataType(223516)
    }

    public var psqlFormat: PostgresFormat {
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
