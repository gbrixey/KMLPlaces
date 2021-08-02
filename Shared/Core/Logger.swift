import Foundation

struct Logger {

    // MARK: - Public

    static func logError(_ error: Error,
                         fileName: String = #file,
                         lineNumber: Int = #line,
                         function: String = #function) {
        logError(error.localizedDescription, fileName: fileName, lineNumber: lineNumber, function: function)
    }

    static func logError(_ error: String,
                         fileName: String = #file,
                         lineNumber: Int = #line,
                         function: String = #function) {
        log("❌ Error: \(error) | \(fileName):\(lineNumber) - \(function)")
    }

    // MARK: - Private

    private static func log(_ message: String) {
        #if DEBUG
        NSLog(message)
        #endif
    }
}
