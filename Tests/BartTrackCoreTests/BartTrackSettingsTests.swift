import XCTest
@testable import BartTrackCore

final class BartTrackSettingsTests: XCTestCase {
    func testDefaultSettingsMatchDalyCityEightMinuteCatchableWidget() {
        XCTAssertEqual(BartTrackSettings.default.station, .dalyCity)
        XCTAssertEqual(BartTrackSettings.default.walkingMinutes, 8)
        XCTAssertTrue(BartTrackSettings.default.showsOnlyCatchableDepartures)
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
