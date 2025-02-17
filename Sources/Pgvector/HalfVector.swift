public struct HalfVector: Equatable {
    public var value: [Float16]

    public init(_ value: [Float16]) {
        self.value = value
    }

    public init?(_ string: String) {
        if (string.count < 2) {
            return nil
        }
        let start = string.index(string.startIndex, offsetBy: 1)
        let end = string.index(string.endIndex, offsetBy: -1)
        let parts = string[start..<end].split(separator: ",")
        let value = parts.compactMap { Float16($0) }
        if parts.count != value.count {
            return nil
        }
        self.value = value
    }

    public static func == (lhs: HalfVector, rhs: HalfVector) -> Bool {
        return lhs.value == rhs.value
    }
}
