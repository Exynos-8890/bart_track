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
}
