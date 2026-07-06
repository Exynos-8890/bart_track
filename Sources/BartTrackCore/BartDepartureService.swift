import Foundation

public protocol BartDataLoading: Sendable {
    func loadData(from url: URL) async throws -> Data
}

public struct URLSessionBartDataLoader: BartDataLoading {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func loadData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw BartDepartureServiceError.badResponse
        }
        return data
    }
}

public enum BartDepartureServiceError: Error, Equatable {
    case badResponse
}

public struct BartDepartureService: Sendable {
    private let dataLoader: any BartDataLoading
    private let decoder: BartETDDecoder
    private let apiKey: String

    public init(
        dataLoader: any BartDataLoading = URLSessionBartDataLoader(),
        decoder: BartETDDecoder = BartETDDecoder(),
        apiKey: String = BartETDRequest.publicAPIKey
    ) {
        self.dataLoader = dataLoader
        self.decoder = decoder
        self.apiKey = apiKey
    }

    public func loadBoard(station: BartStation, walkingMinutes: Int) async throws -> DepartureBoard {
        let request = BartETDRequest(station: station, apiKey: apiKey)
        let data = try await dataLoader.loadData(from: request.url)
        return try decoder.decodeBoard(from: data, station: station, walkingMinutes: walkingMinutes)
    }
}
