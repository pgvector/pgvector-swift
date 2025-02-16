import Testing
@testable import Pgvector

final class HalfVectorTests {
    @Test func equatable() {
        let a = HalfVector([1, 2, 3])
        let b = HalfVector([1, 2, 3])
        let c = HalfVector([1, 2, 4])
        #expect(a == a)
        #expect(a == b)
        #expect(a != c)
    }
}
