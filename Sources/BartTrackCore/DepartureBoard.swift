import Foundation

public enum BartStation: Equatable, Sendable {
    case dalyCity

    public var name: String {
        switch self {
        case .dalyCity: "Daly City"
        }
    }

    public var abbreviation: String {
        switch self {
        case .dalyCity: "DALY"
        }
    }
}

public enum TravelDirection: String, Equatable, Sendable {
    case north
    case south

    init?(bartValue: String) {
        switch bartValue.lowercased() {
        case "north": self = .north
        case "south": self = .south
        default: return nil
        }
    }

    public var title: String {
        switch self {
        case .north: "Northbound"
        case .south: "Southbound"
        }
    }
}

public struct TrainDeparture: Equatable, Identifiable, Sendable {
    public let id: String
    public let destination: String
    public let destinationAbbreviation: String
    public let minutes: Int
    public let direction: TravelDirection
    public let platform: String
    public let lineColor: String
    public let hexColor: String
    public let length: Int?
    public let isDynamic: Bool

    public init(
        destination: String,
        destinationAbbreviation: String,
        minutes: Int,
        direction: TravelDirection,
        platform: String,
        lineColor: String,
        hexColor: String,
        length: Int?,
        isDynamic: Bool
    ) {
        self.destination = destination
        self.destinationAbbreviation = destinationAbbreviation
        self.minutes = minutes
        self.direction = direction
        self.platform = platform
        self.lineColor = lineColor
        self.hexColor = hexColor
        self.length = length
        self.isDynamic = isDynamic
        self.id = "\(direction.rawValue)-\(destinationAbbreviation)-\(minutes)-\(platform)-\(lineColor)"
    }
}

public struct DepartureBoard: Equatable, Sendable {
    public let station: BartStation
    public let generatedAt: Date
    public let walkingMinutes: Int
    public let northbound: [TrainDeparture]
    public let southbound: [TrainDeparture]

    public init(
        station: BartStation,
        generatedAt: Date = Date(),
        walkingMinutes: Int,
        northbound: [TrainDeparture],
        southbound: [TrainDeparture]
    ) {
        self.station = station
        self.generatedAt = generatedAt
        self.walkingMinutes = walkingMinutes
        self.northbound = northbound
        self.southbound = southbound
    }

    public var catchableNorthbound: [TrainDeparture] {
        northbound.filter { $0.minutes >= walkingMinutes }
    }

    public var catchableSouthbound: [TrainDeparture] {
        southbound.filter { $0.minutes >= walkingMinutes }
    }

    public func nextTwo(for direction: TravelDirection) -> [TrainDeparture] {
        Array(departures(for: direction).prefix(2))
    }

    public func nextCatchable(for direction: TravelDirection) -> TrainDeparture? {
        departures(for: direction).first { $0.minutes >= walkingMinutes }
    }

    public func departures(for direction: TravelDirection) -> [TrainDeparture] {
        switch direction {
        case .north: northbound
        case .south: southbound
        }
    }
}
