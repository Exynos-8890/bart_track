import Foundation

public enum BartStation: String, CaseIterable, Codable, Identifiable, Hashable, Sendable {
    case twelfthStreetOakland = "12TH"
    case sixteenthStreetMission = "16TH"
    case nineteenthStreetOakland = "19TH"
    case twentyFourthStreetMission = "24TH"
    case antioch = "ANTC"
    case ashby = "ASHB"
    case balboaPark = "BALB"
    case bayFair = "BAYF"
    case berryessa = "BERY"
    case castroValley = "CAST"
    case civicCenter = "CIVC"
    case coliseum = "COLS"
    case colma = "COLM"
    case concord = "CONC"
    case dalyCity = "DALY"
    case downtownBerkeley = "DBRK"
    case dublinPleasanton = "DUBL"
    case elCerritoDelNorte = "DELN"
    case elCerritoPlaza = "PLZA"
    case embarcadero = "EMBR"
    case fremont = "FRMT"
    case fruitvale = "FTVL"
    case glenPark = "GLEN"
    case hayward = "HAYW"
    case lafayette = "LAFY"
    case lakeMerritt = "LAKE"
    case macArthur = "MCAR"
    case millbrae = "MLBR"
    case milpitas = "MLPT"
    case montgomeryStreet = "MONT"
    case northBerkeley = "NBRK"
    case northConcordMartinez = "NCON"
    case oaklandAirport = "OAKL"
    case orinda = "ORIN"
    case pittsburgBayPoint = "PITT"
    case pittsburgCenter = "PCTR"
    case pleasantHill = "PHIL"
    case powellStreet = "POWL"
    case richmond = "RICH"
    case rockridge = "ROCK"
    case sanBruno = "SBRN"
    case sanFranciscoAirport = "SFIA"
    case sanLeandro = "SANL"
    case southHayward = "SHAY"
    case southSanFrancisco = "SSAN"
    case unionCity = "UCTY"
    case walnutCreek = "WCRK"
    case warmSprings = "WARM"
    case westDublinPleasanton = "WDUB"
    case westOakland = "WOAK"

    public var id: String {
        rawValue
    }

    public var name: String {
        Self.names[self, default: rawValue]
    }

    public var abbreviation: String {
        rawValue
    }

    private static let names: [BartStation: String] = [
        .twelfthStreetOakland: "12th St. Oakland City Center",
        .sixteenthStreetMission: "16th St. Mission",
        .nineteenthStreetOakland: "19th St. Oakland",
        .twentyFourthStreetMission: "24th St. Mission",
        .antioch: "Antioch",
        .ashby: "Ashby",
        .balboaPark: "Balboa Park",
        .bayFair: "Bay Fair",
        .berryessa: "Berryessa/North San Jose",
        .castroValley: "Castro Valley",
        .civicCenter: "Civic Center/UN Plaza",
        .coliseum: "Coliseum",
        .colma: "Colma",
        .concord: "Concord",
        .dalyCity: "Daly City",
        .downtownBerkeley: "Downtown Berkeley",
        .dublinPleasanton: "Dublin/Pleasanton",
        .elCerritoDelNorte: "El Cerrito del Norte",
        .elCerritoPlaza: "El Cerrito Plaza",
        .embarcadero: "Embarcadero",
        .fremont: "Fremont",
        .fruitvale: "Fruitvale",
        .glenPark: "Glen Park",
        .hayward: "Hayward",
        .lafayette: "Lafayette",
        .lakeMerritt: "Lake Merritt",
        .macArthur: "MacArthur",
        .millbrae: "Millbrae",
        .milpitas: "Milpitas",
        .montgomeryStreet: "Montgomery St.",
        .northBerkeley: "North Berkeley",
        .northConcordMartinez: "North Concord/Martinez",
        .oaklandAirport: "Oakland International Airport",
        .orinda: "Orinda",
        .pittsburgBayPoint: "Pittsburg/Bay Point",
        .pittsburgCenter: "Pittsburg Center",
        .pleasantHill: "Pleasant Hill/Contra Costa Centre",
        .powellStreet: "Powell St.",
        .richmond: "Richmond",
        .rockridge: "Rockridge",
        .sanBruno: "San Bruno",
        .sanFranciscoAirport: "San Francisco International Airport",
        .sanLeandro: "San Leandro",
        .southHayward: "South Hayward",
        .southSanFrancisco: "South San Francisco",
        .unionCity: "Union City",
        .walnutCreek: "Walnut Creek",
        .warmSprings: "Warm Springs/South Fremont",
        .westDublinPleasanton: "West Dublin/Pleasanton",
        .westOakland: "West Oakland"
    ]
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
        northbound.filter(isCatchable)
    }

    public var catchableSouthbound: [TrainDeparture] {
        southbound.filter(isCatchable)
    }

    public func nextTwo(for direction: TravelDirection) -> [TrainDeparture] {
        Array(departures(for: direction).prefix(2))
    }

    public func nextCatchable(for direction: TravelDirection) -> TrainDeparture? {
        departures(for: direction).first(where: isCatchable)
    }

    public func departures(for direction: TravelDirection) -> [TrainDeparture] {
        switch direction {
        case .north: northbound
        case .south: southbound
        }
    }

    public func isCatchable(_ departure: TrainDeparture) -> Bool {
        departure.minutes > walkingMinutes
    }
}
