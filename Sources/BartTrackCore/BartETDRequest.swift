import Foundation

public struct BartETDRequest: Equatable, Sendable {
    public static let publicAPIKey = "MW9S-E7SL-26DU-VV8V"

    public let station: BartStation
    public let apiKey: String

    public init(station: BartStation, apiKey: String = Self.publicAPIKey) {
        self.station = station
        self.apiKey = apiKey
    }

    public var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.bart.gov"
        components.path = "/api/etd.aspx"
        components.queryItems = [
            URLQueryItem(name: "cmd", value: "etd"),
            URLQueryItem(name: "orig", value: station.abbreviation),
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "json", value: "y")
        ]
        return components.url!
    }
}
