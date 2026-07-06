import WidgetKit
import XCTest
@testable import BartTrackWidgetKit

final class WidgetFamilyMappingTests: XCTestCase {
    func testMapsWidgetFamiliesToPresentationDensity() {
        XCTAssertEqual(WidgetFamilyMapper.sizeClass(for: .systemSmall), .compact)
        XCTAssertEqual(WidgetFamilyMapper.sizeClass(for: .systemMedium), .rectangular)
        XCTAssertEqual(WidgetFamilyMapper.sizeClass(for: .systemLarge), .expanded)
        XCTAssertEqual(WidgetFamilyMapper.sizeClass(for: .systemExtraLarge), .expanded)
    }

    func testTimelineScheduleRequestsRefreshBeforeStaleEntryDisplays() {
        let now = Date(timeIntervalSince1970: 1_783_317_600)
        let schedule = BartTrackTimelineSchedule(now: now, refreshInterval: 30, staleInterval: 90)

        XCTAssertEqual(schedule.refreshAt, now.addingTimeInterval(30))
        XCTAssertEqual(schedule.staleAt, now.addingTimeInterval(90))
        XCTAssertLessThan(schedule.refreshAt, schedule.staleAt)
    }
}
