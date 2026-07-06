import Foundation

public struct BartETDDecoder: Sendable {
    public init() {}

    public func decodeBoard(from data: Data, station: BartStation, walkingMinutes: Int) throws -> DepartureBoard {
        let response = try JSONDecoder().decode(BartETDResponse.self, from: data)
        let stationPayload = response.root.station.values.first { $0.abbr == station.abbreviation }
        let departures = stationPayload?.etd.values.flatMap { etd in
            etd.estimate.values.compactMap { estimate -> TrainDeparture? in
                guard estimate.cancelflag != "1",
                      let minutes = Self.parseMinutes(estimate.minutes),
                      let direction = TravelDirection(bartValue: estimate.direction)
                else {
                    return nil
                }

                return TrainDeparture(
                    destination: etd.destination,
                    destinationAbbreviation: etd.abbreviation,
                    minutes: minutes,
                    direction: direction,
                    platform: estimate.platform,
                    lineColor: estimate.color,
                    hexColor: estimate.hexcolor,
                    length: Int(estimate.length),
                    isDynamic: estimate.dynamicflag == "1"
                )
            }
        } ?? []

        let sortedDepartures = departures.sorted { lhs, rhs in
            if lhs.minutes == rhs.minutes {
                return lhs.destination < rhs.destination
            }
            return lhs.minutes < rhs.minutes
        }

        return DepartureBoard(
            station: station,
            walkingMinutes: walkingMinutes,
            northbound: sortedDepartures.filter { $0.direction == .north },
            southbound: sortedDepartures.filter { $0.direction == .south }
        )
    }

    private static func parseMinutes(_ value: String) -> Int? {
        if value.lowercased() == "leaving" {
            return 0
        }
        return Int(value)
    }
}

private struct BartETDResponse: Decodable {
    let root: Root

    struct Root: Decodable {
        let station: OneOrMany<Station>
    }

    struct Station: Decodable {
        let name: String
        let abbr: String
        let etd: OneOrMany<ETD>
    }

    struct ETD: Decodable {
        let destination: String
        let abbreviation: String
        let estimate: OneOrMany<Estimate>
    }

    struct Estimate: Decodable {
        let minutes: String
        let platform: String
        let direction: String
        let length: String
        let color: String
        let hexcolor: String
        let cancelflag: String
        let dynamicflag: String
    }
}

private struct OneOrMany<Value: Decodable>: Decodable {
    let values: [Value]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let many = try? container.decode([Value].self) {
            values = many
        } else {
            values = [try container.decode(Value.self)]
        }
    }
}
