public struct HalfVector: Equatable {
    public var value: [Float16]

    public init(_ value: [Float16]) {
        self.value = value
    }

    public static func == (lhs: HalfVector, rhs: HalfVector) -> Bool {
        return lhs.value == rhs.value
    }
}
