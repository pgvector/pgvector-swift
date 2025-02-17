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
}
