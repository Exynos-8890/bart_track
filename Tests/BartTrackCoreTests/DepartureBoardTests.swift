import XCTest
@testable import BartTrackCore

final class DepartureBoardTests: XCTestCase {
    func testDecodesDalyCityNorthAndSouthEstimatesAndSkipsCanceledTrains() throws {
        let data = bartFixture.data(using: .utf8)!

        let board = try BartETDDecoder().decodeBoard(from: data, station: .dalyCity, walkingMinutes: 8)

        XCTAssertEqual(board.station.name, "Daly City")
        XCTAssertEqual(board.northbound.map(\.destination), ["Richmond", "Antioch"])
        XCTAssertEqual(board.northbound.map(\.minutes), [4, 11])
        XCTAssertEqual(board.southbound.map(\.destination), ["Millbrae", "SFO"])
        XCTAssertEqual(board.southbound.map(\.minutes), [7, 19])
        XCTAssertEqual(board.catchableNorthbound.map(\.minutes), [11])
        XCTAssertEqual(board.catchableSouthbound.map(\.minutes), [19])
    }

    func testLeavingIsTreatedAsZeroMinutesAndNextTwoAreSorted() throws {
        let data = bartFixture.replacingOccurrences(of: "\"4\"", with: "\"Leaving\"", options: [], range: bartFixture.range(of: "\"4\""))
            .data(using: .utf8)!

        let board = try BartETDDecoder().decodeBoard(from: data, station: .dalyCity, walkingMinutes: 8)

        XCTAssertEqual(board.northbound.map(\.minutes), [0, 11])
        XCTAssertEqual(board.nextTwo(for: .north).map(\.minutes), [0, 11])
        XCTAssertEqual(board.nextCatchable(for: .north)?.minutes, 11)
    }

    func testBuildsOfficialBartEtdURLForDalyCityJSON() throws {
        let url = BartETDRequest(station: .dalyCity, apiKey: "TEST-KEY").url

        XCTAssertEqual(
            url.absoluteString,
            "https://api.bart.gov/api/etd.aspx?cmd=etd&orig=DALY&key=TEST-KEY&json=y"
        )
    }
}

private let bartFixture = """
{
  "root": {
    "date": "07/06/2026",
    "time": "08:13:44 AM PDT",
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
                "minutes": "4",
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
                "minutes": "11",
                "platform": "2",
                "direction": "North",
                "length": "8",
                "color": "YELLOW",
                "hexcolor": "#ffff33",
                "cancelflag": "0",
                "dynamicflag": "1"
              }
            ]
          },
          {
            "destination": "Berryessa",
            "abbreviation": "BERY",
            "estimate": [
              {
                "minutes": "14",
                "platform": "2",
                "direction": "North",
                "length": "8",
                "color": "GREEN",
                "hexcolor": "#339933",
                "cancelflag": "1",
                "dynamicflag": "0"
              }
            ]
          },
          {
            "destination": "Millbrae",
            "abbreviation": "MLBR",
            "estimate": [
              {
                "minutes": "7",
                "platform": "1",
                "direction": "South",
                "length": "8",
                "color": "RED",
                "hexcolor": "#ff0000",
                "cancelflag": "0",
                "dynamicflag": "0"
              }
            ]
          },
          {
            "destination": "SFO",
            "abbreviation": "SFIA",
            "estimate": [
              {
                "minutes": "19",
                "platform": "1",
                "direction": "South",
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
    ],
    "message": ""
  }
}
"""
