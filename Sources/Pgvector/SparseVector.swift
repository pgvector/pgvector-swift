public struct SparseVector: Equatable {
    public private(set) var dim: Int
    public private(set) var indices: [Int]
    public private(set) var values: [Float]

    public init(_ value: [Float]) {
        var indices: [Int] = []
        var values: [Float] = []
        for (i, v) in value.enumerated() {
            if (v != 0) {
                indices.append(i)
                values.append(v)
            }
        }

        self.dim = value.count
        self.indices = indices
        self.values = values
    }

    public init?(_ string: String) {
        return nil
    }

    public func text() -> String {
        let elements = zip(indices, values).map { String($0 + 1) + ":" + String($1) }.joined(separator: ",")
        return "{" + elements + "}/" + String(dim)
    }

    public static func == (lhs: SparseVector, rhs: SparseVector) -> Bool {
        return lhs.dim == rhs.dim && lhs.indices == rhs.indices && lhs.values == rhs.values
    }
}
