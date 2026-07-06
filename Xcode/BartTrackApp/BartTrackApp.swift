import SwiftUI
import WidgetKit

@main
struct BartTrackApp: App {
    var body: some Scene {
        WindowGroup {
            VStack(alignment: .leading, spacing: 12) {
                Text("Bart Track")
                    .font(.title.bold())
                Text("Add the Daly City BART widget from Notification Center or Desktop widget editing.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(28)
            .frame(width: 420)
            .onAppear {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}
