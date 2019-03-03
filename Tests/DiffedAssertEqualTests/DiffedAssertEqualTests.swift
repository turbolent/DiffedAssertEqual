import XCTest
import DiffedAssertEqual

final class DiffedAssertEqualTests: XCTestCase {

    func testDiffedAssertEqual() {
        diffedAssertEqual("Hello, World!", "Hello, World!")
        diffedAssertEqual("Hello, World!", "Hello, World!", "strings are unequal")
    }

    func testDiffedAssertJSONEqual() {
        if #available(OSX 10.13, *) {
            diffedAssertJSONEqual(
                """
                { "hello"   : "world"}
                """,
                ["hello": "world"]
            )
        } else {
            // Fallback on earlier versions
        }
    }
}
