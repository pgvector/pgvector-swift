public struct Vector: Equatable {
    public var value: [Float]

    init(_ value: [Float]) {
        self.value = value
    }

    public static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.value == rhs.value
    }
}
