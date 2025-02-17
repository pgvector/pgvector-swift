public struct Vector: Equatable {
    public private(set) var value: [Float]

    public init(_ value: [Float]) {
        self.value = value
    }

    public init?(_ string: String) {
        if (string.count < 2) {
            return nil
        }
        let start = string.index(string.startIndex, offsetBy: 1)
        let end = string.index(string.endIndex, offsetBy: -1)
        let parts = string[start..<end].split(separator: ",")
        let value = parts.compactMap { Float($0) }
        if parts.count != value.count {
            return nil
        }
        self.value = value
    }

    public static func == (lhs: Vector, rhs: Vector) -> Bool {
        return lhs.value == rhs.value
    }
}
