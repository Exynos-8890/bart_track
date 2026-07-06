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
    private let logger: BartTrackDebugLogger

    public init(
        dataLoader: any BartDataLoading = URLSessionBartDataLoader(),
        decoder: BartETDDecoder = BartETDDecoder(),
        apiKey: String = BartETDRequest.publicAPIKey,
        logger: BartTrackDebugLogger = BartTrackDebugLogger()
    ) {
        self.dataLoader = dataLoader
        self.decoder = decoder
        self.apiKey = apiKey
        self.logger = logger
    }

    public func loadBoard(station: BartStation, walkingMinutes: Int) async throws -> DepartureBoard {
        let request = BartETDRequest(station: station, apiKey: apiKey)
        logger.log(
            "service.request.start",
            metadata: [
                "station": station.abbreviation,
                "url": request.url.absoluteString
            ]
        )

        do {
            let data = try await dataLoader.loadData(from: request.url)
            let board = try decoder.decodeBoard(from: data, station: station, walkingMinutes: walkingMinutes)
            logger.log(
                "service.request.success",
                metadata: [
                    "generatedAt": "\(Int(board.generatedAt.timeIntervalSince1970))",
                    "north": "\(board.northbound.count)",
                    "south": "\(board.southbound.count)",
                    "station": station.abbreviation
                ]
            )
            return board
        } catch {
            logger.log(
                "service.request.failure",
                metadata: [
                    "error": String(describing: error),
                    "station": station.abbreviation
                ]
            )
            throw error
        }
    }
}
