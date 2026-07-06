import XCTest
import BartTrackCore
@testable import BartTrackWidgetUI

final class WidgetPresentationTests: XCTestCase {
    func testSmallWidgetKeepsOneCatchableTrainPerDirection() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .compact)

        XCTAssertEqual(presentation.sections.map(\.direction), [.north, .south])
        XCTAssertEqual(presentation.sections.map { $0.rows.map(\.minutes) }, [[11], [19]])
    }

    func testRectangularWidgetKeepsNextTwoTrainsPerDirection() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .rectangular)

        XCTAssertEqual(presentation.sections.map { $0.rows.map(\.minutes) }, [[4, 11], [7, 19]])
    }

    func testExpandedWidgetKeepsAllVisibleTrainsCappedAtFourPerDirection() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .expanded)

        XCTAssertEqual(presentation.sections.first?.rows.map(\.minutes), [4, 11, 22, 31])
        XCTAssertEqual(presentation.sections.last?.rows.map(\.minutes), [7, 19])
        XCTAssertEqual(presentation.catchableSummary, "N 4 / S 1 after 8 min")
    }
}

private let sampleBoard = DepartureBoard(
    station: .dalyCity,
    generatedAt: Date(timeIntervalSince1970: 1_783_317_600),
    walkingMinutes: 8,
    northbound: [
        departure(destination: "Richmond", minutes: 4, direction: .north),
        departure(destination: "Antioch", minutes: 11, direction: .north),
        departure(destination: "Berryessa", minutes: 22, direction: .north),
        departure(destination: "Dublin", minutes: 31, direction: .north),
        departure(destination: "Richmond", minutes: 43, direction: .north)
    ],
    southbound: [
        departure(destination: "Millbrae", minutes: 7, direction: .south),
        departure(destination: "SFO", minutes: 19, direction: .south)
    ]
)

private func departure(destination: String, minutes: Int, direction: TravelDirection) -> TrainDeparture {
    TrainDeparture(
        destination: destination,
        destinationAbbreviation: String(destination.prefix(4)).uppercased(),
        minutes: minutes,
        direction: direction,
        platform: direction == .north ? "2" : "1",
        lineColor: "RED",
        hexColor: "#ff0000",
        length: 8,
        isDynamic: false
    )
}
