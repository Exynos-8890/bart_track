import BartTrackWidgetUI
import SwiftUI
import WidgetKit

public struct BartTrackWidget: Widget {
    public let kind = "BartTrackWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BartTrackTimelineProvider()) { entry in
            BartTrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daly City BART")
        .description("Northbound and southbound departures with an 8-minute walking buffer.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

private struct BartTrackWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family

    let entry: BartTrackEntry

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            BartDepartureWidgetView(
                board: entry.board,
                sizeClass: WidgetFamilyMapper.sizeClass(for: family)
            )

            if let errorMessage = entry.errorMessage {
                Text(errorMessage)
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.red.opacity(0.82), in: Capsule())
                    .padding(10)
            }
        }
    }
}
