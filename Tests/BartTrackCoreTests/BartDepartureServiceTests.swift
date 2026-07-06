import XCTest
@testable import BartTrackCore

final class BartDepartureServiceTests: XCTestCase {
    func testLoadsDalyCityBoardThroughConfiguredDataLoader() async throws {
        let loader = StubDataLoader(data: serviceFixture.data(using: .utf8)!)
        let service = BartDepartureService(dataLoader: loader, apiKey: "TEST-KEY")

        let board = try await service.loadBoard(station: .dalyCity, walkingMinutes: 8)

        XCTAssertEqual(loader.requestedURLs.map(\.absoluteString), [
            "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=DALY&key=TEST-KEY&json=y"
        ])
        XCTAssertEqual(board.northbound.map(\.minutes), [5, 16])
        XCTAssertEqual(board.catchableNorthbound.map(\.minutes), [16])
    }
}

private final class StubDataLoader: BartDataLoading, @unchecked Sendable {
    private(set) var requestedURLs: [URL] = []
    private let data: Data

    init(data: Data) {
        self.data = data
    }

    func loadData(from url: URL) async throws -> Data {
        requestedURLs.append(url)
        return data
    }
}

private let serviceFixture = """
{
  "root": {
    "station": [
      {
        "name": "Daly City",
        "abbr": "DALY",
        "etd": [
          {
            "destination": "Richmond",
            "abbreviation": "RICH",
            "estimate": [
              {
                "minutes": "5",
                "platform": "2",
                "direction": "North",
                "length": "8",
                "color": "RED",
                "hexcolor": "#ff0000",
                "cancelflag": "0",
                "dynamicflag": "0"
              }
            ]
          },
          {
            "destination": "Antioch",
            "abbreviation": "ANTC",
            "estimate": [
              {
                "minutes": "16",
                "platform": "2",
                "direction": "North",
                "length": "8",
                "color": "YELLOW",
                "hexcolor": "#ffff33",
                "cancelflag": "0",
                "dynamicflag": "0"
              }
            ]
          }
        ]
      }
    ]
  }
}
"""
