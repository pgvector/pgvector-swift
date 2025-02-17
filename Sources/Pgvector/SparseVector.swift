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
        let parts = string.split(separator: "/", maxSplits: 3)
        if parts.count != 2 || parts[0].first != "{" || parts[0].last != "}" {
            return nil
        }

        let elements = parts[0]
        let dim = Int(parts[1])
        if dim == nil {
            return nil
        }
        var indices: [Int] = []
        var values: [Float] = []

        if (elements.count > 2) {
            let start = elements.index(elements.startIndex, offsetBy: 1)
            let end = elements.index(elements.endIndex, offsetBy: -1)
            for e in elements[start..<end].split(separator: ",") {
                let ep = e.split(separator: ":", maxSplits: 3)
                if ep.count != 2 {
                    return nil
                }
                if let i = Int(ep[0]), let v = Float(ep[1]) {
                    indices.append(i - 1)
                    values.append(v)
                } else {
                    return nil
                }
            }
        }

        self.dim = dim!
        self.indices = indices
        self.values = values
    }

    public func text() -> String {
        let elements = zip(indices, values).map { String($0 + 1) + ":" + String($1) }
        return "{" + elements.joined(separator: ",") + "}/" + String(dim)
    }

    public static func == (lhs: SparseVector, rhs: SparseVector) -> Bool {
        return lhs.dim == rhs.dim && lhs.indices == rhs.indices && lhs.values == rhs.values
    }
}
