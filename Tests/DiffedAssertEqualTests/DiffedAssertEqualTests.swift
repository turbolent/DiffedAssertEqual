import XCTest
import DiffedAssertEqual

final class DiffedAssertEqualTests: XCTestCase {
    func testExample() {
        diffedAssertEqual("Hello, World!", "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
