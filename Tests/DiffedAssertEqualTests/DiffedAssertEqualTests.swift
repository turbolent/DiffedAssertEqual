import XCTest
import DiffedAssertEqual

final class DiffedAssertEqualTests: XCTestCase {

    func testExample() {
        diffedAssertEqual("Hello, World!", "Hello, World!")
        diffedAssertEqual("Hello, World!", "Hello, World!", "strings are unequal")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
