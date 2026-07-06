import BartTrackCore
import SwiftUI
import WidgetKit

@main
struct BartTrackApp: App {
    var body: some Scene {
        WindowGroup {
            BartTrackSettingsView()
        }
    }
}

private struct BartTrackSettingsView: View {
    private let store: BartTrackSettingsStore

    @State private var settings: BartTrackSettings
    @State private var debugLines: [String] = []
    @State private var statusText = ""

    init(store: BartTrackSettingsStore = BartTrackSettingsStore()) {
        self.store = store
        _settings = State(initialValue: store.load())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Bart Track")
                    .font(.title.bold())
                Text("Widget Settings")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Form {
                Picker("Station", selection: $settings.station) {
                    ForEach(BartStation.allCases) { station in
                        Text(station.name).tag(station)
                    }
                }

                Stepper(value: $settings.walkingMinutes, in: 0...60) {
                    HStack {
                        Text("Walking time")
                        Spacer()
                        Text("\(settings.walkingMinutes) min")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle("Show only later trains", isOn: $settings.showsOnlyCatchableDepartures)
            }
            .formStyle(.grouped)

            HStack(spacing: 10) {
                Button("Reload Widget") {
                    persistSettings()
                }
                .buttonStyle(.borderedProminent)

                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Configuration File")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(store.configurationURL.path(percentEncoded: false))
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Debug Log")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(BartTrackDebugLogger().logURL.path(percentEncoded: false))
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .lineLimit(2)
                    .minimumScaleFactor(0.75)

                if debugLines.isEmpty {
                    Text("No debug events yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 3) {
                            ForEach(debugLines, id: \.self) { line in
                                Text(line)
                                    .font(.caption2.monospaced())
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .frame(minHeight: 82, maxHeight: 120)
                }
            }
        }
        .padding(28)
        .frame(width: 540)
        .onAppear {
            persistSettings()
            refreshDebugLines()
        }
        .onChange(of: settings) { _, _ in
            persistSettings()
        }
    }

    private func persistSettings() {
        do {
            try store.save(settings)
            WidgetCenter.shared.reloadAllTimelines()
            statusText = "Saved \(Self.timeFormatter.string(from: Date()))"
            refreshDebugLines()
        } catch {
            statusText = "Save failed"
        }
    }

    private func refreshDebugLines() {
        debugLines = BartTrackDebugLogger().recentLines(limit: 12)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
