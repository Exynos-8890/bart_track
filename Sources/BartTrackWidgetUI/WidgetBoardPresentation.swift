import BartTrackCore
import Foundation

public enum WidgetSizeClass: Equatable, Sendable {
    case compact
    case rectangular
    case expanded
}

public struct WidgetBoardPresentation: Equatable, Sendable {
    public struct Section: Equatable, Sendable {
        public let direction: TravelDirection
        public let rows: [TrainDeparture]
        public let catchableCount: Int

        public init(direction: TravelDirection, rows: [TrainDeparture], catchableCount: Int) {
            self.direction = direction
            self.rows = rows
            self.catchableCount = catchableCount
        }
    }

    public let board: DepartureBoard
    public let sizeClass: WidgetSizeClass
    public let showsOnlyCatchableDepartures: Bool
    public let sections: [Section]

    public init(
        board: DepartureBoard,
        sizeClass: WidgetSizeClass,
        showsOnlyCatchableDepartures: Bool = BartTrackSettings.default.showsOnlyCatchableDepartures
    ) {
        self.board = board
        self.sizeClass = sizeClass
        self.showsOnlyCatchableDepartures = showsOnlyCatchableDepartures
        self.sections = [.north, .south].map { direction in
            Section(
                direction: direction,
                rows: Self.visibleRows(
                    board: board,
                    direction: direction,
                    sizeClass: sizeClass,
                    showsOnlyCatchableDepartures: showsOnlyCatchableDepartures
                ),
                catchableCount: board.departures(for: direction).filter(board.isCatchable).count
            )
        }
    }

    public var catchableSummary: String {
        let northCount = sections.first { $0.direction == .north }?.catchableCount ?? 0
        let southCount = sections.first { $0.direction == .south }?.catchableCount ?? 0
        return "N \(northCount) / S \(southCount) after \(board.walkingMinutes) min"
    }

    private static func visibleRows(
        board: DepartureBoard,
        direction: TravelDirection,
        sizeClass: WidgetSizeClass,
        showsOnlyCatchableDepartures: Bool
    ) -> [TrainDeparture] {
        let departures = board.departures(for: direction)
        let visibleDepartures = showsOnlyCatchableDepartures ? departures.filter(board.isCatchable) : departures

        switch sizeClass {
        case .compact:
            return Array(visibleDepartures.prefix(3))
        case .rectangular:
            return Array(visibleDepartures.prefix(4))
        case .expanded:
            return Array(visibleDepartures.prefix(8))
        }
    }
}
