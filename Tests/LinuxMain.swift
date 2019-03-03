import XCTest

import DiffedAssertEqualTests

var tests = [XCTestCaseEntry]()
tests += DiffedAssertEqualTests.__allTests()

XCTMain(tests)
