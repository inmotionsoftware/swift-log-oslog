import XCTest
@testable import LoggingOSLog
import Logging

final class OSLogHandlerTests: XCTestCase {
    func testExample() {
        LoggingSystem.bootstrap {
            OSLogHandler(label: $0, metadataContentType: .public)
        }

        let logger = Logger(label: "OSLogHandlerTests/Logging")
        logger.info("Hello World")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
