import Pgvector
import Testing

final class SparseVectorTests {
    @Test func equatable() {
        let a = SparseVector([1, 0, 2, 0, 3, 0])
        let b = SparseVector([1, 0, 2, 0, 3, 0])
        let c = SparseVector([1, 0, 2, 0, 4, 0])
        #expect(a == a)
        #expect(a == b)
        #expect(a != c)
    }

    @Test func fromDictionary() {
        let a = SparseVector([2: 2, 4: 3, 1: 0, 0: 1], dim: 6)!
        #expect(a.dim == 6)
        #expect(a.indices == [0, 2, 4])
        #expect(a.values == [1, 2, 3])
    }
}
