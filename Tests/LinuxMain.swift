import XCTest

import DiffedAssertEqualTests

var tests = [XCTestCaseEntry]()
tests += DiffedAssertEqualTests.allTests()
XCTMain(tests)