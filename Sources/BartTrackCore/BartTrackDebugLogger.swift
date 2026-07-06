import Foundation

public struct BartTrackDebugLogger: Sendable {
    public static let prefix = "[BARTTRACK-DEBUG]"

    public let logURL: URL

    public init(settingsStore: BartTrackSettingsStore = BartTrackSettingsStore()) {
        self.logURL = settingsStore.configurationURL
            .deletingLastPathComponent()
            .appendingPathComponent("debug.log")
    }

    public init(logURL: URL) {
        self.logURL = logURL
    }

    public func log(_ event: String, metadata: [String: String] = [:], date: Date = Date()) {
        let line = Self.formatLine(event: event, metadata: metadata, date: date)

        do {
            try FileManager.default.createDirectory(
                at: logURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            if FileManager.default.fileExists(atPath: logURL.path(percentEncoded: false)) {
                let handle = try FileHandle(forWritingTo: logURL)
                try handle.seekToEnd()
                try handle.write(contentsOf: Data(line.utf8))
                try handle.close()
            } else {
                try line.write(to: logURL, atomically: true, encoding: .utf8)
            }
        } catch {
            // Debug logging must never affect widget rendering or BART loading.
        }
    }

    public func recentLines(limit: Int = 80) -> [String] {
        guard let text = try? String(contentsOf: logURL, encoding: .utf8) else {
            return []
        }

        return Array(text.split(separator: "\n").suffix(limit).map(String.init))
    }

    private static func formatLine(event: String, metadata: [String: String], date: Date) -> String {
        let fields = metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")

        if fields.isEmpty {
            return "\(timestampFormatter.string(from: date)) \(prefix) \(event)\n"
        }
        return "\(timestampFormatter.string(from: date)) \(prefix) \(event) \(fields)\n"
    }

    private static let timestampFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
