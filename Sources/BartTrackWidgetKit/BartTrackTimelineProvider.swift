import BartTrackCore
import Foundation
import WidgetKit

public struct BartTrackEntry: TimelineEntry {
    public let date: Date
    public let board: DepartureBoard
    public let errorMessage: String?

    public init(date: Date, board: DepartureBoard, errorMessage: String? = nil) {
        self.date = date
        self.board = board
        self.errorMessage = errorMessage
    }
}

public struct BartTrackTimelineProvider: TimelineProvider {
    private let service: BartDepartureService
    private let refreshInterval: TimeInterval

    public init(
        service: BartDepartureService = BartDepartureService(),
        refreshInterval: TimeInterval = 60
    ) {
        self.service = service
        self.refreshInterval = refreshInterval
    }

    public func placeholder(in context: Context) -> BartTrackEntry {
        BartTrackEntry(date: Date(), board: .placeholder)
    }

    public func getSnapshot(in context: Context, completion: @escaping (BartTrackEntry) -> Void) {
        completion(BartTrackEntry(date: Date(), board: .placeholder))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<BartTrackEntry>) -> Void) {
        Task {
            let now = Date()
            let entry: BartTrackEntry

            do {
                let board = try await service.loadBoard(station: .dalyCity, walkingMinutes: 8)
                entry = BartTrackEntry(date: now, board: board)
            } catch {
                entry = BartTrackEntry(
                    date: now,
                    board: .placeholder,
                    errorMessage: "BART feed unavailable"
                )
            }

            completion(Timeline(entries: [entry], policy: .after(now.addingTimeInterval(refreshInterval))))
        }
    }
}

private extension DepartureBoard {
    static let placeholder = DepartureBoard(
        station: .dalyCity,
        generatedAt: Date(),
        walkingMinutes: 8,
        northbound: [
            TrainDeparture(
                destination: "Richmond",
                destinationAbbreviation: "RICH",
                minutes: 4,
                direction: .north,
                platform: "2",
                lineColor: "RED",
                hexColor: "#ff0000",
                length: 8,
                isDynamic: false
            ),
            TrainDeparture(
                destination: "Antioch",
                destinationAbbreviation: "ANTC",
                minutes: 11,
                direction: .north,
                platform: "2",
                lineColor: "YELLOW",
                hexColor: "#ffff33",
                length: 8,
                isDynamic: false
            )
        ],
        southbound: [
            TrainDeparture(
                destination: "Millbrae",
                destinationAbbreviation: "MLBR",
                minutes: 7,
                direction: .south,
                platform: "1",
                lineColor: "RED",
                hexColor: "#ff0000",
                length: 8,
                isDynamic: false
            ),
            TrainDeparture(
                destination: "SFO",
                destinationAbbreviation: "SFIA",
                minutes: 19,
                direction: .south,
                platform: "1",
                lineColor: "YELLOW",
                hexColor: "#ffff33",
                length: 8,
                isDynamic: false
            )
        ]
    )
}
