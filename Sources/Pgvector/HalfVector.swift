public struct HalfVector: Equatable {
    public private(set) var value: [Float16]

    public init(_ value: [Float16]) {
        self.value = value
    }

    public init?(_ string: String) {
        guard string.count >= 2, string.first == "[", string.last == "]" else {
            return nil
        }
        let start = string.index(string.startIndex, offsetBy: 1)
        let end = string.index(string.endIndex, offsetBy: -1)
        let parts = string[start..<end].split(separator: ",")
        let value = parts.compactMap { Float16($0) }
        guard parts.count == value.count else {
            return nil
        }
        self.value = value
    }

    public func text() -> String {
        return "[" + value.map { String($0) }.joined(separator: ",") + "]"
    }

    public static func == (lhs: HalfVector, rhs: HalfVector) -> Bool {
        return lhs.value == rhs.value
    }
}
