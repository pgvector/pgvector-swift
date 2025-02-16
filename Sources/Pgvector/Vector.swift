#if canImport(PostgresClientKit)
import PostgresClientKit
#endif

struct Vector: Equatable {
    var value: [Float]

    init(_ value: [Float]) {
        self.value = value
    }

    static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.value == rhs.value
    }
}

#if canImport(PostgresClientKit)
extension Vector: PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: value))
    }
}
#endif
