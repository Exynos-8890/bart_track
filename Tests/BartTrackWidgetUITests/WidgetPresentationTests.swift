import XCTest
import BartTrackCore
@testable import BartTrackWidgetUI

final class WidgetPresentationTests: XCTestCase {
    func testSmallWidgetShowsNextThreeCatchableTrainsByDefault() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .compact)

        XCTAssertEqual(presentation.sections.map(\.direction), [.north, .south])
        XCTAssertEqual(presentation.sections.map { $0.rows.map(\.minutes) }, [[11, 22, 31], [19, 26, 34]])
    }

    func testCanShowUnfilteredNextTrainsWhenCatchableFilterIsOff() {
        let presentation = WidgetBoardPresentation(
            board: sampleBoard,
            sizeClass: .compact,
            showsOnlyCatchableDepartures: false
        )

        XCTAssertEqual(presentation.sections.map { $0.rows.map(\.minutes) }, [[4, 11, 22], [7, 19, 26]])
    }

    func testRectangularWidgetKeepsFourCatchableTrainsPerDirection() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .rectangular)

        XCTAssertEqual(presentation.sections.map { $0.rows.map(\.minutes) }, [[11, 22, 31, 43], [19, 26, 34, 48]])
    }

    func testRectangularWidgetKeepsChronologicalOrderAfterFilteringCatchableRows() {
        let presentation = WidgetBoardPresentation(board: colorDiverseBoard, sizeClass: .rectangular)
        let northRows = presentation.sections.first { $0.direction == .north }?.rows

        XCTAssertEqual(northRows?.map(\.minutes), [10, 16, 19, 22])
        XCTAssertEqual(northRows?.map(\.lineColor), ["RED", "BLUE", "GREEN", "YELLOW"])
    }

    func testExpandedWidgetKeepsEightCatchableTrainsPerDirection() {
        let presentation = WidgetBoardPresentation(board: sampleBoard, sizeClass: .expanded)

        XCTAssertEqual(presentation.sections.first?.rows.map(\.minutes), [11, 22, 31, 43, 51, 62, 75, 88])
        XCTAssertEqual(presentation.sections.last?.rows.map(\.minutes), [19, 26, 34, 48, 57, 66, 74, 89])
        XCTAssertEqual(presentation.catchableSummary, "N 8 / S 8 after 8 min")
    }

    func testZeroWalkingMinutesIsAllowedAndStillHidesLeavingTrains() {
        let presentation = WidgetBoardPresentation(board: zeroWalkingBoard, sizeClass: .compact)

        XCTAssertEqual(presentation.sections.first?.rows.map(\.minutes), [1, 4])
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
        departure(destination: "Richmond", minutes: 43, direction: .north),
        departure(destination: "Antioch", minutes: 51, direction: .north),
        departure(destination: "Berryessa", minutes: 62, direction: .north),
        departure(destination: "Dublin", minutes: 75, direction: .north),
        departure(destination: "Richmond", minutes: 88, direction: .north)
    ],
    southbound: [
        departure(destination: "Millbrae", minutes: 7, direction: .south),
        departure(destination: "SFO", minutes: 19, direction: .south),
        departure(destination: "Millbrae", minutes: 26, direction: .south),
        departure(destination: "SFO", minutes: 34, direction: .south),
        departure(destination: "Millbrae", minutes: 48, direction: .south),
        departure(destination: "SFO", minutes: 57, direction: .south),
        departure(destination: "Millbrae", minutes: 66, direction: .south),
        departure(destination: "SFO", minutes: 74, direction: .south),
        departure(destination: "Millbrae", minutes: 89, direction: .south)
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

private let zeroWalkingBoard = DepartureBoard(
    station: .dalyCity,
    generatedAt: Date(timeIntervalSince1970: 1_783_317_600),
    walkingMinutes: 0,
    northbound: [
        departure(destination: "Leaving", minutes: 0, direction: .north),
        departure(destination: "Richmond", minutes: 1, direction: .north),
        departure(destination: "Antioch", minutes: 4, direction: .north)
    ],
    southbound: []
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
