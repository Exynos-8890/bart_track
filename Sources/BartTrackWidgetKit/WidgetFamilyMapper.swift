import BartTrackWidgetUI
import WidgetKit

public enum WidgetFamilyMapper {
    public static func sizeClass(for family: WidgetFamily) -> WidgetSizeClass {
        switch family {
        case .systemSmall, .accessoryRectangular, .accessoryInline, .accessoryCircular:
            return .compact
        case .systemMedium:
            return .rectangular
        case .systemLarge, .systemExtraLarge:
            return .expanded
        @unknown default:
            return .rectangular
        }
    }
}
