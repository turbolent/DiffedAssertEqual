import XCTest

public func diffedAssertEqual<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String? = nil,
    file: StaticString = #file,
    line: UInt = #line
) where T : Equatable {

    func fail(_ message: String) {
        XCTFail(message, file: file, line: line)
    }

    let value1: T
    do {
        value1 = try expression1()
    } catch let e {
        fail("expression 1 failed: \(e)")
        return
    }

    let value2: T
    do {
        value2 = try expression2()
    } catch let e {
        fail("expression 2 failed: \(e)")
        return
    }

    if value1 != value2,
        let diffMessage = diff(value1, value2, file: file, line: line)
    {
        var finalMessage = ""
        if let initialMessage = message() {
            finalMessage += initialMessage
        }
        finalMessage += "\n"
        // omit diff header (first two lines)
        let diffParts = diffMessage.split(
            separator: "\n",
            maxSplits: 2,
            omittingEmptySubsequences: false
        )
        finalMessage += diffParts[2]
        fail(finalMessage)
    }
}

internal func diff<T>(_ value1: T, _ value2: T, file: StaticString, line: UInt) -> String? {
    func fail(_ message: String) {
        XCTFail(message, file: file, line: line)
    }

    let file1: TemporaryFile
    do {
        file1 = try dumpToFile(value1)
    } catch let e {
        fail("failed to open temp file 1: \(e)")
        return nil
    }
    defer { file1.delete() }

    let file2: TemporaryFile
    do {
        file2 = try dumpToFile(value2)
    } catch let e {
        fail("failed to open temp file 2: \(e)")
        return nil
    }
    defer { file2.delete() }

    guard
        case let (output?, status) =
            shell("/usr/bin/diff", ["-u", file1.path, file2.path]),
        status == 1
    else {
        fail("failed to diff")
        return nil
    }

    return output
}

internal func dumpToFile<T>(_ value: T) throws -> TemporaryFile {
    var file = try TemporaryFile()
    if let string = value as? String {
        file.write(string)
    } else {
        dump(value, to: &file)
    }
    file.close()
    return file
}

internal func shell(_ launchPath: String, _ arguments: [String] = []) -> (String?, Int32) {
    let task = Process()
    task.launchPath = launchPath
    task.arguments = arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)
    task.waitUntilExit()
    return (output, task.terminationStatus)
}

internal final class TemporaryFile {

    enum Error: Swift.Error {
        case failedToCreate
    }

    private let url: URL
    private let fileManager: FileManager
    private let fileHandle: FileHandle

    internal var path: String {
        return url.path
    }

    internal init(fileManager: FileManager = FileManager.default) throws {
        self.fileManager = fileManager

        let name = UUID().uuidString
        let path = NSTemporaryDirectory()
        url = URL(fileURLWithPath: path)
            .appendingPathComponent(name)

        let created = fileManager.createFile(
            atPath: url.path,
            contents: nil,
            attributes: nil
        )

        guard created else {
            throw Error.failedToCreate
        }

        fileHandle = try FileHandle(forWritingTo: url)
    }

    internal func close() {
        fileHandle.closeFile()
    }

    internal func delete() {
        DispatchQueue.global(qos: .utility).async { [fileManager, url] in
            try? fileManager.removeItem(at: url)
        }
    }
}

extension TemporaryFile : TextOutputStream {
    public func write(_ string: String) {
        guard let data = string.data(using: .utf8) else { return }
        fileHandle.write(data)
    }
}


@available(OSX 10.13, *)
public func diffedAssertJSONEqual<T>(
    _ expected: String,
    _ actual: T,
    file: StaticString = #file,
    line: UInt = #line
)
    where T: Encodable
{
    do {
        guard let expectedData = expected.data(using: .utf8) else {
            XCTFail("failed to UTF8-decode expected string")
            return
        }
        let actualData = try JSONEncoder().encode(actual)
        diffedAssertEqual(
            try encodeToSortedPrettyJSON(data: actualData),
            try encodeToSortedPrettyJSON(data: expectedData),
            file: file,
            line: line
        )
    } catch let error {
        XCTFail(
            error.localizedDescription,
            file: file,
            line: line
        )
    }
}

@available(OSX 10.13, *)
private func encodeToSortedPrettyJSON(data: Data) throws -> String? {
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
    let sortedPrettyJSONData = try JSONSerialization.data(
        withJSONObject: jsonObject,
        options: [.sortedKeys, .prettyPrinted]
    )
    return String(data: sortedPrettyJSONData, encoding: .utf8)
}
