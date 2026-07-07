import XCTest
@testable import BartTrackCore

final class BartTrackSettingsTests: XCTestCase {
    func testDefaultSettingsMatchDalyCityEightMinuteCatchableWidget() {
        XCTAssertEqual(BartTrackSettings.default.station, .dalyCity)
        XCTAssertEqual(BartTrackSettings.default.walkingMinutes, 8)
        XCTAssertTrue(BartTrackSettings.default.showsOnlyCatchableDepartures)
        XCTAssertFalse(BartTrackSettings.default.showsDockIcon)
        XCTAssertEqual(BartTrackSettings.default.openURL?.host, "www.bart.gov")
        XCTAssertEqual(BartTrackSettings.default.openURL?.path, "/schedules/eta/DALY")
    }

    func testLiveBartDeepLinkTargetsAppURLScheme() {
        XCTAssertEqual(BartTrackSettings.liveBartDeepLinkURL.scheme, "barttrack")
        XCTAssertEqual(BartTrackSettings.liveBartDeepLinkURL.host, "open-live-bart")
    }

    func testOldSettingsFilesUseDefaultOpenURL() throws {
        let data = """
        {
          "showsOnlyCatchableDepartures" : true,
          "station" : "DALY",
          "walkingMinutes" : 8
        }
        """.data(using: .utf8)!

        let settings = try JSONDecoder().decode(BartTrackSettings.self, from: data)

        XCTAssertEqual(settings.openURLString, BartTrackSettings.defaultOpenURLString)
    }

    func testSettingsClampWalkingMinutesToSupportedRange() {
        XCTAssertEqual(
            BartTrackSettings(station: .dalyCity, walkingMinutes: -4, showsOnlyCatchableDepartures: true).walkingMinutes,
            0
        )
        XCTAssertEqual(
            BartTrackSettings(station: .dalyCity, walkingMinutes: 88, showsOnlyCatchableDepartures: true).walkingMinutes,
            60
        )
    }

    func testSettingsStoreRoundTripsConfigurationFile() throws {
        let configurationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("settings.json")
        let store = BartTrackSettingsStore(configurationURL: configurationURL)
        let settings = BartTrackSettings(
            station: .dalyCity,
            walkingMinutes: 0,
            showsOnlyCatchableDepartures: false
        )

        try store.save(settings)

        XCTAssertEqual(store.load(), settings)
    }

    func testFallbackConfigurationPathWritesFromAppIntoWidgetContainer() {
        let store = BartTrackSettingsStore(bundleIdentifier: "com.local.BartTrack")
        let expectedSuffix = "Library/Containers/com.local.BartTrack.WidgetExtension/Data/Library/Application Support/BartTrack/settings.json"

        XCTAssertTrue(store.configurationURL.path(percentEncoded: false).hasSuffix(expectedSuffix))
    }

    func testFallbackConfigurationPathReadsInsideWidgetContainerHome() {
        let store = BartTrackSettingsStore(bundleIdentifier: BartTrackSettingsStore.widgetExtensionBundleIdentifier)
        let expectedSuffix = "Library/Application Support/BartTrack/settings.json"

        XCTAssertTrue(store.configurationURL.path(percentEncoded: false).hasSuffix(expectedSuffix))
        XCTAssertFalse(store.configurationURL.path(percentEncoded: false).contains("Containers/com.local.BartTrack.WidgetExtension/Data/Library/Containers"))
    }
}
