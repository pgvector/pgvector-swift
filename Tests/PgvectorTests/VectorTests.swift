import Testing
@testable import Pgvector

final class VectorTests {
    @Test func equatable() {
        let a = Vector([1, 2, 3])
        let b = Vector([1, 2, 3])
        let c = Vector([1, 2, 4])
        #expect(a == a)
        #expect(a == b)
        #expect(a != c)
    }
}
