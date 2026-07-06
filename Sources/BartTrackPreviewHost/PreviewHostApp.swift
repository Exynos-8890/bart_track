import BartTrackCore
import BartTrackWidgetUI
import SwiftUI

@main
struct PreviewHostApp: App {
    var body: some Scene {
        WindowGroup("BartTrack Widget Preview") {
            PreviewHostView()
                .frame(width: 960, height: 420)
        }
        .windowResizability(.contentSize)
    }
}

private struct PreviewHostView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 22) {
            PreviewCard(title: "1x1", width: 158, height: 158, sizeClass: .compact)
            PreviewCard(title: "1x2", width: 338, height: 158, sizeClass: .rectangular)
            PreviewCard(title: "2x2", width: 338, height: 338, sizeClass: .expanded)
        }
        .padding(28)
        .frame(width: 960, height: 420, alignment: .topLeading)
        .background(Color(red: 0.90, green: 0.93, blue: 0.95))
    }
}

private struct PreviewCard: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    let sizeClass: WidgetSizeClass

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(Color(red: 0.22, green: 0.27, blue: 0.31))

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
            previewDeparture(destination: "Berryessa", minutes: 0, direction: .north, color: "GREEN", hexColor: "#339933"),
            previewDeparture(destination: "Pittsburg/Bay Point", minutes: 5, direction: .north, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(destination: "Richmond", minutes: 10, direction: .north, color: "RED", hexColor: "#ff0000"),
            previewDeparture(destination: "Antioch", minutes: 14, direction: .north, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(destination: "Dublin/Pleasanton", minutes: 16, direction: .north, color: "BLUE", hexColor: "#0099cc"),
            previewDeparture(destination: "Berryessa", minutes: 19, direction: .north, color: "GREEN", hexColor: "#339933")
        ],
        southbound: [
            previewDeparture(destination: "SF Airport", minutes: 7, direction: .south, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(destination: "Millbrae", minutes: 13, direction: .south, color: "RED", hexColor: "#ff0000"),
            previewDeparture(destination: "SF Airport", minutes: 18, direction: .south, color: "YELLOW", hexColor: "#ffff33"),
            previewDeparture(destination: "Millbrae", minutes: 33, direction: .south, color: "RED", hexColor: "#ff0000")
        ]
    )

    static func previewDeparture(
        destination: String,
        minutes: Int,
        direction: TravelDirection,
        color: String,
        hexColor: String
    ) -> TrainDeparture {
        TrainDeparture(
            destination: destination,
            destinationAbbreviation: String(destination.prefix(4)).uppercased(),
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
