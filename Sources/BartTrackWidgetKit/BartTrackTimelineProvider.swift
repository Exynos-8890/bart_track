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

public struct BartTrackTimelineSchedule: Equatable, Sendable {
    public let refreshAt: Date
    public let staleAt: Date

    public init(now: Date, refreshInterval: TimeInterval, staleInterval: TimeInterval) {
        self.refreshAt = now.addingTimeInterval(refreshInterval)
        self.staleAt = now.addingTimeInterval(staleInterval)
    }
}

public struct BartTrackTimelineProvider: TimelineProvider {
    private let service: BartDepartureService
    private let refreshInterval: TimeInterval
    private let staleInterval: TimeInterval
    private let logger: BartTrackDebugLogger

    public init(
        service: BartDepartureService = BartDepartureService(),
        refreshInterval: TimeInterval = 30,
        staleInterval: TimeInterval = 90,
        logger: BartTrackDebugLogger = BartTrackDebugLogger()
    ) {
        self.service = service
        self.refreshInterval = refreshInterval
        self.staleInterval = staleInterval
        self.logger = logger
    }

    public func placeholder(in context: Context) -> BartTrackEntry {
        BartTrackEntry(date: Date(), board: .placeholder(settings: .default), settings: .default)
    }

    public func getSnapshot(in context: Context, completion: @escaping (BartTrackEntry) -> Void) {
        let settings = BartTrackSettingsStore().load()
        logger.log(
            "timeline.snapshot",
            metadata: [
                "filterCatchable": "\(settings.showsOnlyCatchableDepartures)",
                "station": settings.station.abbreviation,
                "walkingMinutes": "\(settings.walkingMinutes)"
            ]
        )
        completion(BartTrackEntry(date: Date(), board: .placeholder(settings: settings), settings: settings))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<BartTrackEntry>) -> Void) {
        Task {
            let now = Date()
            let settings = BartTrackSettingsStore().load()
            let schedule = BartTrackTimelineSchedule(
                now: now,
                refreshInterval: refreshInterval,
                staleInterval: staleInterval
            )
            let entry: BartTrackEntry

            logger.log(
                "timeline.start",
                metadata: [
                    "filterCatchable": "\(settings.showsOnlyCatchableDepartures)",
                    "refreshAt": "\(Int(schedule.refreshAt.timeIntervalSince1970))",
                    "staleAt": "\(Int(schedule.staleAt.timeIntervalSince1970))",
                    "station": settings.station.abbreviation,
                    "walkingMinutes": "\(settings.walkingMinutes)"
                ],
                date: now
            )

            do {
                let board = try await service.loadBoard(
                    station: settings.station,
                    walkingMinutes: settings.walkingMinutes
                )
                entry = BartTrackEntry(date: now, board: board, settings: settings, freshness: .fresh)
                logger.log(
                    "timeline.loaded",
                    metadata: [
                        "generatedAt": "\(Int(board.generatedAt.timeIntervalSince1970))",
                        "north": "\(board.northbound.count)",
                        "south": "\(board.southbound.count)"
                    ]
                )
            } catch {
                entry = BartTrackEntry(
                    date: now,
                    board: .placeholder(settings: settings),
                    settings: settings,
                    freshness: .stale,
                    errorMessage: "BART feed unavailable"
                )
                logger.log(
                    "timeline.load.failed",
                    metadata: [
                        "error": String(describing: error)
                    ]
                )
            }

            let staleEntry = BartTrackEntry(
                date: schedule.staleAt,
                board: entry.board,
                settings: settings,
                freshness: .stale,
                errorMessage: entry.errorMessage
            )
            logger.log(
                "timeline.complete",
                metadata: [
                    "entryCount": "2",
                    "policyAfter": "\(Int(schedule.refreshAt.timeIntervalSince1970))",
                    "staleEntryDate": "\(Int(staleEntry.date.timeIntervalSince1970))"
                ]
            )
            completion(
                Timeline(
                    entries: [entry, staleEntry],
                    policy: .after(schedule.refreshAt)
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
