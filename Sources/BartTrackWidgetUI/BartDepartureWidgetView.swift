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
        VStack(alignment: .leading, spacing: 10) {
            HeaderView(board: presentation.board, showsSummary: false)

            VStack(spacing: 8) {
                ForEach(presentation.sections, id: \.direction) { section in
                    CompactDirectionView(section: section)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
    }

    private var rectangularContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeaderView(board: presentation.board, showsSummary: true, summary: presentation.catchableSummary)

            HStack(alignment: .top, spacing: 10) {
                ForEach(presentation.sections, id: \.direction) { section in
                    DirectionSectionView(section: section, isExpanded: false)
                }
            }
        }
        .padding(16)
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderView(board: presentation.board, showsSummary: true, summary: presentation.catchableSummary)

            VStack(spacing: 10) {
                ForEach(presentation.sections, id: \.direction) { section in
                    DirectionSectionView(section: section, isExpanded: true)
                }
            }
        }
        .padding(18)
    }
}

private struct HeaderView: View {
    let board: DepartureBoard
    var showsSummary: Bool
    var summary: String = ""

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DALY")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundStyle(.white)
                Text("Updated now")
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.64))
            }

            Spacer(minLength: 8)

            if showsSummary {
                Text(summary)
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            } else {
                Text("walk \(board.walkingMinutes)")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.bartBlue)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.94), in: Capsule())
            }
        }
    }
}

private struct CompactDirectionView: View {
    let section: WidgetBoardPresentation.Section

    var body: some View {
        HStack(spacing: 8) {
            DirectionBadge(direction: section.direction)

            if let train = section.rows.first {
                VStack(alignment: .leading, spacing: 1) {
                    Text(train.destination)
                        .font(.system(.caption, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("next catchable")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.58))
                }

                Spacer(minLength: 4)

                MinutesView(minutes: train.minutes, color: Color(hex: train.hexColor))
            } else {
                Text("No catchable train")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(1)
            }
        }
        .padding(9)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct DirectionSectionView: View {
    let section: WidgetBoardPresentation.Section
    let isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                DirectionBadge(direction: section.direction)
                Text("\(section.catchableCount) catchable")
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            VStack(spacing: isExpanded ? 7 : 6) {
                if section.rows.isEmpty {
                    EmptyRow()
                } else {
                    ForEach(section.rows) { train in
                        TrainRow(train: train, isExpanded: isExpanded)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(isExpanded ? 12 : 10)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct TrainRow: View {
    let train: TrainDeparture
    let isExpanded: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: train.hexColor))
                .frame(width: 7, height: 7)

            VStack(alignment: .leading, spacing: 1) {
                Text(train.destination)
                    .font(.system(isExpanded ? .caption : .caption2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if isExpanded {
                    Text("Platform \(train.platform)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.white.opacity(0.54))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 6)

            MinutesView(minutes: train.minutes, color: Color(hex: train.hexColor))
        }
    }
}

private struct EmptyRow: View {
    var body: some View {
        Text("No trains posted")
            .font(.system(.caption2, design: .rounded).weight(.medium))
            .foregroundStyle(.white.opacity(0.62))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
    }
}

private struct DirectionBadge: View {
    let direction: TravelDirection

    var body: some View {
        Text(direction == .north ? "N" : "S")
            .font(.system(.caption2, design: .rounded).weight(.heavy))
            .foregroundStyle(direction == .north ? Color.bartBlue : Color.bartMint)
            .frame(width: 24, height: 24)
            .background(.white.opacity(0.92), in: Circle())
            .accessibilityLabel(Text(direction.title))
    }
}

private struct MinutesView: View {
    let minutes: Int
    let color: Color

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(minutes)")
                .font(.system(.title3, design: .rounded).weight(.heavy))
                .monospacedDigit()
            Text("m")
                .font(.system(.caption2, design: .rounded).weight(.bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.72), in: Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.18), lineWidth: 1))
        .lineLimit(1)
        .minimumScaleFactor(0.75)
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
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        guard cleaned.count == 6,
              let value = UInt64(cleaned, radix: 16)
        else {
            self = .bartBlue
            return
        }

        self = Color(
            red: Double((value >> 16) & 0xff) / 255,
            green: Double((value >> 8) & 0xff) / 255,
            blue: Double(value & 0xff) / 255
        )
    }
}
