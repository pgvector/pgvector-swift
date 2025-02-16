#if canImport(PostgresClientKit)
import PostgresClientKit
#endif

struct HalfVector: Equatable {
    var value: [Float16]

    init(_ value: [Float16]) {
        self.value = value
    }

    static func == (lhs: HalfVector, rhs: HalfVector) -> Bool {
        return lhs.value == rhs.value
    }
}

#if canImport(PostgresClientKit)
extension HalfVector: PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: value))
    }
}
#endif
