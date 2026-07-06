import Foundation

public struct BartTrackSettings: Codable, Equatable, Sendable {
    public static let `default` = BartTrackSettings(
        station: .dalyCity,
        walkingMinutes: 8,
        showsOnlyCatchableDepartures: true
    )

    public var station: BartStation
    public var walkingMinutes: Int
    public var showsOnlyCatchableDepartures: Bool

    public init(
        station: BartStation,
        walkingMinutes: Int,
        showsOnlyCatchableDepartures: Bool
    ) {
        self.station = station
        self.walkingMinutes = Self.clampedWalkingMinutes(walkingMinutes)
        self.showsOnlyCatchableDepartures = showsOnlyCatchableDepartures
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
    }

    public static func clampedWalkingMinutes(_ value: Int) -> Int {
        min(max(value, 0), 60)
    }
}

public struct BartTrackSettingsStore: Sendable {
    public static let appGroupIdentifier = "group.com.local.BartTrack"
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
        if let appGroupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            return appGroupURL.appendingPathComponent("settings.json")
        }

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
