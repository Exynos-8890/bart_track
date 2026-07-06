import XCTest
@testable import BartTrackCore

final class BartTrackDebugLoggerTests: XCTestCase {
    func testDebugLoggerWritesTaggedEventLines() {
        let logURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("debug.log")
        let logger = BartTrackDebugLogger(logURL: logURL)

        logger.log(
            "timeline.start",
            metadata: [
                "station": "DALY",
                "walkingMinutes": "8"
            ],
            date: Date(timeIntervalSince1970: 1_783_317_600)
        )

        let lines = logger.recentLines()
        XCTAssertEqual(lines.count, 1)
        XCTAssertTrue(lines[0].contains(BartTrackDebugLogger.prefix))
        XCTAssertTrue(lines[0].contains("timeline.start"))
        XCTAssertTrue(lines[0].contains("station=DALY"))
        XCTAssertTrue(lines[0].contains("walkingMinutes=8"))
    }
}
