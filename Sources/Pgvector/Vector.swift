// TODO make conditional
import PostgresClientKit

struct Vector: Equatable {
    var value: [Float]

    init(_ value: [Float]) {
        self.value = value
    }

    static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.value == rhs.value
    }
}

// TODO make conditional
extension Vector: PostgresValueConvertible {
    public var postgresValue: PostgresValue {
        return PostgresValue(String(describing: value))
    }
}
