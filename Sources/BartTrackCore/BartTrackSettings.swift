import Foundation

public struct BartTrackSettings: Codable, Equatable, Sendable {
    public static let defaultOpenURLString = "https://www.bart.gov/schedules/eta/DALY"
    public static let liveBartDeepLinkURL = URL(string: "barttrack://open-live-bart")!

    public static let `default` = BartTrackSettings(
        station: .dalyCity,
        walkingMinutes: 8,
        showsOnlyCatchableDepartures: true,
        showsDockIcon: false,
        openURLString: defaultOpenURLString
    )

    public var station: BartStation
    public var walkingMinutes: Int
    public var showsOnlyCatchableDepartures: Bool
    public var showsDockIcon: Bool
    public var openURLString: String

    public init(
        station: BartStation,
        walkingMinutes: Int,
        showsOnlyCatchableDepartures: Bool,
        showsDockIcon: Bool = false,
        openURLString: String = Self.defaultOpenURLString
    ) {
        self.station = station
        self.walkingMinutes = Self.clampedWalkingMinutes(walkingMinutes)
        self.showsOnlyCatchableDepartures = showsOnlyCatchableDepartures
        self.showsDockIcon = showsDockIcon
        self.openURLString = openURLString
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.station = try container.decodeIfPresent(BartStation.self, forKey: .station) ?? Self.default.station
        self.walkingMinutes = Self.clampedWalkingMinutes(
            try container.decodeIfPresent(Int.self, forKey: .walkingMinutes) ?? Self.default.walkingMinutes
        )
        self.showsOnlyCatchableDepartures = try container.decodeIfPresent(
            Bool.self,
            forKey: .showsOnlyCatchableDepartures
        ) ?? Self.default.showsOnlyCatchableDepartures
        self.showsDockIcon = try container.decodeIfPresent(
            Bool.self,
            forKey: .showsDockIcon
        ) ?? Self.default.showsDockIcon
        self.openURLString = try container.decodeIfPresent(
            String.self,
            forKey: .openURLString
        ) ?? Self.default.openURLString
    }

    public var openURL: URL? {
        URL(string: openURLString.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    public static func clampedWalkingMinutes(_ value: Int) -> Int {
        min(max(value, 0), 60)
    }
}

public struct BartTrackSettingsStore: Sendable {
    public static let widgetExtensionBundleIdentifier = "com.local.BartTrack.WidgetExtension"

    public let configurationURL: URL

    public init(
        configurationURL: URL? = nil,
        fileManager: FileManager = .default,
        bundleIdentifier: String? = Bundle.main.bundleIdentifier
    ) {
        self.configurationURL = configurationURL ?? Self.defaultConfigurationURL(
            fileManager: fileManager,
            bundleIdentifier: bundleIdentifier
        )
    }

    public func load() -> BartTrackSettings {
        guard let data = try? Data(contentsOf: configurationURL),
              let settings = try? JSONDecoder().decode(BartTrackSettings.self, from: data)
        else {
            return .default
        }

        return settings
    }

    public func save(_ settings: BartTrackSettings) throws {
        try FileManager.default.createDirectory(
            at: configurationURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(settings)
        try data.write(to: configurationURL, options: .atomic)
    }

    private static func defaultConfigurationURL(fileManager: FileManager, bundleIdentifier: String?) -> URL {
        let homeURL = fileManager.homeDirectoryForCurrentUser
        if bundleIdentifier == widgetExtensionBundleIdentifier {
            return homeURL
                .appendingPathComponent("Library", isDirectory: true)
                .appendingPathComponent("Application Support", isDirectory: true)
                .appendingPathComponent("BartTrack", isDirectory: true)
                .appendingPathComponent("settings.json")
        }

        return homeURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Containers", isDirectory: true)
            .appendingPathComponent(widgetExtensionBundleIdentifier, isDirectory: true)
            .appendingPathComponent("Data", isDirectory: true)
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
            .appendingPathComponent("BartTrack", isDirectory: true)
            .appendingPathComponent("settings.json")
    }
}
