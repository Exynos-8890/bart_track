import AppKit
import BartTrackCore
import BartTrackWidgetUI
import SwiftUI

@main
struct SnapshotApp {
    @MainActor
    static func main() throws {
        let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "widget-preview.png")
        let view = SnapshotSheet()
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        renderer.proposedSize = ProposedViewSize(width: 960, height: 420)

        guard let image = renderer.nsImage,
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:])
        else {
            throw SnapshotError.renderFailed
        }

        try pngData.write(to: outputURL)
        print(outputURL.path)
    }
}

private enum SnapshotError: Error {
    case renderFailed
}

private struct SnapshotSheet: View {
    var body: some View {
        HStack(alignment: .top, spacing: 22) {
            SnapshotCard(title: "1x1", width: 158, height: 158, sizeClass: .compact)
            SnapshotCard(title: "1x2", width: 338, height: 158, sizeClass: .rectangular)
            SnapshotCard(title: "2x2", width: 338, height: 338, sizeClass: .expanded)
        }
        .padding(28)
        .frame(width: 960, height: 420, alignment: .topLeading)
        .background(Color(red: 0.12, green: 0.13, blue: 0.15))
    }
}

private struct SnapshotCard: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let sizeClass: WidgetSizeClass

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(.white.opacity(0.72))

            BartDepartureWidgetView(board: .preview, sizeClass: sizeClass)
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }
}

private extension DepartureBoard {
    static let preview = DepartureBoard(
        station: .dalyCity,
        generatedAt: Date(),
        walkingMinutes: 8,
        northbound: [
            previewDeparture(minutes: 4, direction: .north, color: "BLUE", hexColor: "#0099cc"),
            previewDeparture(minutes: 11, direction: .north, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(minutes: 30, direction: .north, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(minutes: 50, direction: .north, color: "YELLOW", hexColor: "#ffff33")
        ],
        southbound: [
            previewDeparture(minutes: 6, direction: .south, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(minutes: 26, direction: .south, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(minutes: 46, direction: .south, color: "YELLOW", hexColor: "#ffff33")
        ]
    )

    static func previewDeparture(
        minutes: Int,
        direction: TravelDirection,
        color: String,
        hexColor: String
    ) -> TrainDeparture {
        TrainDeparture(
            destination: direction == .north ? "Antioch" : "SFO/Millbrae",
            destinationAbbreviation: direction == .north ? "ANTC" : "MLBR",
            minutes: minutes,
            direction: direction,
            platform: direction == .north ? "2" : "3",
            lineColor: color,
            hexColor: hexColor,
            length: 8,
            isDynamic: false
        )
    }
}
