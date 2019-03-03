import XCTest

extension DiffedAssertEqualTests {
    static let __allTests = [
        ("testDiffedAssertEqual", testDiffedAssertEqual),
        ("testDiffedAssertJSONEqual", testDiffedAssertJSONEqual),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(DiffedAssertEqualTests.__allTests),
    ]
}
#endif
