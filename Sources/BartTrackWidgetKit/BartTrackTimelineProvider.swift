import BartTrackCore
import BartTrackWidgetUI
import Foundation
import WidgetKit

public struct BartTrackEntry: TimelineEntry {
    public let date: Date
    public let board: DepartureBoard
    public let settings: BartTrackSettings
    public let freshness: WidgetDataFreshness
    public let errorMessage: String?

    public init(
        date: Date,
        board: DepartureBoard,
        settings: BartTrackSettings = .default,
        freshness: WidgetDataFreshness = .fresh,
        errorMessage: String? = nil
    ) {
        self.date = date
        self.board = board
        self.settings = settings
        self.freshness = freshness
        self.errorMessage = errorMessage
    }
}

public struct BartTrackTimelineProvider: TimelineProvider {
    private let service: BartDepartureService
    private let refreshInterval: TimeInterval
    private let staleInterval: TimeInterval

    public init(
        service: BartDepartureService = BartDepartureService(),
        refreshInterval: TimeInterval = 30,
        staleInterval: TimeInterval = 90
    ) {
        self.service = service
        self.refreshInterval = refreshInterval
        self.staleInterval = staleInterval
    }

    public func placeholder(in context: Context) -> BartTrackEntry {
        BartTrackEntry(date: Date(), board: .placeholder(settings: .default), settings: .default)
    }

    public func getSnapshot(in context: Context, completion: @escaping (BartTrackEntry) -> Void) {
        let settings = BartTrackSettingsStore().load()
        completion(BartTrackEntry(date: Date(), board: .placeholder(settings: settings), settings: settings))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<BartTrackEntry>) -> Void) {
        Task {
            let now = Date()
            let settings = BartTrackSettingsStore().load()
            let entry: BartTrackEntry

            do {
                let board = try await service.loadBoard(
                    station: settings.station,
                    walkingMinutes: settings.walkingMinutes
                )
                entry = BartTrackEntry(date: now, board: board, settings: settings, freshness: .fresh)
            } catch {
                entry = BartTrackEntry(
                    date: now,
                    board: .placeholder(settings: settings),
                    settings: settings,
                    freshness: .stale,
                    errorMessage: "BART feed unavailable"
                )
            }

            let staleEntry = BartTrackEntry(
                date: now.addingTimeInterval(staleInterval),
                board: entry.board,
                settings: settings,
                freshness: .stale,
                errorMessage: entry.errorMessage
            )
            completion(
                Timeline(
                    entries: [entry, staleEntry],
                    policy: .after(now.addingTimeInterval(refreshInterval))
                )
            )
        }
    }
}

private extension DepartureBoard {
    static func placeholder(settings: BartTrackSettings) -> DepartureBoard {
        DepartureBoard(
            station: settings.station,
            generatedAt: Date(),
            walkingMinutes: settings.walkingMinutes,
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
}
