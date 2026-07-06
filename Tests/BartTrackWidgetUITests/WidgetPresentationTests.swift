import XCTest
import BartTrackCore
@testable import BartTrackWidgetUI

final class WidgetPresentationTests: XCTestCase {
    func testSmallWidgetKeepsNextTwoTrainsPerDirection() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .compact)

        XCTAssertEqual(presentation.sections.map(\.direction), [.north, .south])
        XCTAssertEqual(presentation.sections.map { $0.rows.map(\.minutes) }, [[4, 11], [7, 19]])
    }

    func testRectangularWidgetKeepsFourTrainsPerDirection() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .rectangular)

        XCTAssertEqual(presentation.sections.map { $0.rows.map(\.minutes) }, [[4, 11, 22, 31], [7, 19]])
    }

    func testRectangularWidgetKeepsChronologicalOrderEvenWhenLineColorsRepeat() {
        let presentation = WidgetBoardPresentation(board: colorDiverseBoard, sizeClass: .rectangular)
        let northRows = presentation.sections.first { $0.direction == .north }?.rows

        XCTAssertEqual(northRows?.map(\.minutes), [5, 8, 10, 16])
        XCTAssertEqual(northRows?.map(\.lineColor), ["YELLOW", "YELLOW", "RED", "BLUE"])
    }

    func testExpandedWidgetKeepsFourTrainsPerDirection() {
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

private let colorDiverseBoard = DepartureBoard(
    station: .dalyCity,
    generatedAt: Date(timeIntervalSince1970: 1_783_317_600),
    walkingMinutes: 8,
    northbound: [
        departure(destination: "Pittsburg/Bay Point", minutes: 5, direction: .north, color: "YELLOW", hexColor: "#ffff33"),
        departure(destination: "Antioch", minutes: 8, direction: .north, color: "YELLOW", hexColor: "#ffff33"),
        departure(destination: "Richmond", minutes: 10, direction: .north, color: "RED", hexColor: "#ff0000"),
        departure(destination: "Dublin/Pleasanton", minutes: 16, direction: .north, color: "BLUE", hexColor: "#0099cc"),
        departure(destination: "Berryessa", minutes: 19, direction: .north, color: "GREEN", hexColor: "#339933"),
        departure(destination: "Pittsburg/Bay Point", minutes: 22, direction: .north, color: "YELLOW", hexColor: "#ffff33")
    ],
    southbound: [
        departure(destination: "SF Airport", minutes: 7, direction: .south, color: "YELLOW", hexColor: "#ffff33"),
        departure(destination: "Millbrae", minutes: 13, direction: .south, color: "RED", hexColor: "#ff0000")
    ]
)

private func departure(
    destination: String,
    minutes: Int,
    direction: TravelDirection,
    color: String = "RED",
    hexColor: String = "#ff0000"
) -> TrainDeparture {
    TrainDeparture(
        destination: destination,
        destinationAbbreviation: String(destination.prefix(4)).uppercased(),
        minutes: minutes,
        direction: direction,
        platform: direction == .north ? "2" : "1",
        lineColor: color,
        hexColor: hexColor,
        length: 8,
        isDynamic: false
    )
}
