import BartTrackCore
import SwiftUI
import WidgetKit

public struct BartDepartureWidgetView: View {
    private let presentation: WidgetBoardPresentation

    public init(board: DepartureBoard, sizeClass: WidgetSizeClass) {
        self.presentation = WidgetBoardPresentation(board: board, sizeClass: sizeClass)
    }

    public var body: some View {
        ZStack {
            content
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
        .containerShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    @ViewBuilder
    private var content: some View {
        switch presentation.sizeClass {
        case .compact:
            compactContent
        case .rectangular:
            rectangularContent
        case .expanded:
            expandedContent
        }
    }

    private var compactContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            CompactHeaderView(board: presentation.board)
            ForEach(presentation.sections, id: \.direction) { section in
                CompactDirectionView(section: section)
            }
        }
        .padding(10)
    }

    private var rectangularContent: some View {
        VStack(alignment: .leading, spacing: 9) {
            HeaderView(board: presentation.board)

            HStack(alignment: .top, spacing: 8) {
                ForEach(presentation.sections, id: \.direction) { section in
                    DirectionSectionView(section: section, isExpanded: false)
                }
            }
        }
        .padding(12)
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            HeaderView(board: presentation.board)

            VStack(spacing: 12) {
                ForEach(presentation.sections, id: \.direction) { section in
                    DirectionSectionView(section: section, isExpanded: true)
                }
            }
        }
        .padding(14)
    }
}

private struct CompactHeaderView: View {
    let board: DepartureBoard

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Text("DALY")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.86))

            Spacer(minLength: 4)

            Text("+\(board.walkingMinutes)")
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.bartBlue)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(.white.opacity(0.94), in: Capsule())
        }
    }
}

private struct HeaderView: View {
    let board: DepartureBoard

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Text("DALY")
                .font(.system(.caption, design: .rounded).weight(.heavy))
                .foregroundStyle(.white)

            Spacer(minLength: 8)

            Text("+\(board.walkingMinutes)m")
                .font(.system(.caption2, design: .rounded).weight(.heavy))
                .monospacedDigit()
                .foregroundStyle(Color.bartBlue)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(.white.opacity(0.94), in: Capsule())
        }
    }
}

private struct CompactDirectionView: View {
    let section: WidgetBoardPresentation.Section

    var body: some View {
        HStack(spacing: 7) {
            Text(section.direction == .north ? "N" : "S")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))
                .frame(width: 17, alignment: .leading)

            if let train = section.rows.first {
                MinuteTile(train: train, isLarge: true)
            } else {
                EmptyRow(isCompact: true)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

private struct DirectionSectionView: View {
    let section: WidgetBoardPresentation.Section
    let isExpanded: Bool

    var body: some View {
        DirectionPanel(section: section, isExpanded: isExpanded)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

private struct DirectionPanel: View {
    let section: WidgetBoardPresentation.Section
    let isExpanded: Bool

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: isExpanded ? 96 : 48), spacing: 8)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isExpanded ? 9 : 6) {
            DirectionBadge(direction: section.direction)

            if section.rows.isEmpty {
                EmptyRow(isCompact: false)
            } else if isExpanded {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
                    ForEach(section.rows) { train in
                        MinuteTile(train: train, isLarge: true)
                    }
                }
            } else {
                HStack(spacing: 6) {
                    ForEach(section.rows) { train in
                        MinuteTile(train: train, isLarge: section.rows.count == 1)
                    }
                }
            }
        }
        .padding(isExpanded ? 12 : 9)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct MinuteTile: View {
    let train: TrainDeparture
    let isLarge: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(train.minutes)")
                .font(.system(isLarge ? .title2 : .title3, design: .rounded).weight(.heavy))
                .monospacedDigit()
            Text("m")
                .font(.system(.caption2, design: .rounded).weight(.heavy))
        }
        .foregroundStyle(Color.readableText(onHex: train.hexColor))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity, minHeight: isLarge ? 43 : 36)
        .padding(.horizontal, isLarge ? 8 : 6)
        .background(Color(hex: train.hexColor).opacity(0.82), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        )
        .accessibilityLabel(Text("\(train.direction.title), \(train.minutes) minutes"))
    }
}

private struct EmptyRow: View {
    let isCompact: Bool

    var body: some View {
        Text("--")
            .font(.system(.title3, design: .rounded).weight(.heavy))
            .monospacedDigit()
            .foregroundStyle(.white.opacity(0.62))
            .frame(maxWidth: .infinity, minHeight: isCompact ? 43 : 36)
            .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct DirectionBadge: View {
    let direction: TravelDirection

    var body: some View {
        Text(direction == .north ? "NORTH" : "SOUTH")
            .font(.system(.caption2, design: .rounded).weight(.heavy))
            .foregroundStyle(.white.opacity(0.72))
            .lineLimit(1)
            .accessibilityLabel(Text(direction.title))
    }
}

private struct WidgetBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.07, blue: 0.10),
                Color(red: 0.03, green: 0.12, blue: 0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.bartBlue.opacity(0.24))
                .frame(width: 120, height: 120)
                .blur(radius: 32)
                .offset(x: 42, y: -48)
        }
        .overlay(alignment: .bottomLeading) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .offset(y: -10)
        }
    }
}

private extension Color {
    static let bartBlue = Color(red: 0.00, green: 0.45, blue: 0.78)
    static let bartMint = Color(red: 0.40, green: 0.86, blue: 0.70)

    init(hex: String) {
        guard let rgb = Self.rgbComponents(from: hex) else {
            self = .bartBlue
            return
        }

        self = Color(
            red: Double(rgb.red) / 255,
            green: Double(rgb.green) / 255,
            blue: Double(rgb.blue) / 255
        )
    }

    static func readableText(onHex hex: String) -> Color {
        guard let rgb = rgbComponents(from: hex) else {
            return .white
        }

        let luminance = (0.299 * Double(rgb.red) + 0.587 * Double(rgb.green) + 0.114 * Double(rgb.blue)) / 255
        return luminance > 0.62 ? Color(red: 0.07, green: 0.08, blue: 0.08) : .white
    }

    private static func rgbComponents(from hex: String) -> (red: UInt64, green: UInt64, blue: UInt64)? {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16)
        else {
            return nil
        }

        return (
            red: (value >> 16) & 0xff,
            green: (value >> 8) & 0xff,
            blue: value & 0xff
        )
    }
}
