// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BartTrack",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "BartTrackCore", targets: ["BartTrackCore"]),
        .library(name: "BartTrackWidgetUI", targets: ["BartTrackWidgetUI"]),
        .library(name: "BartTrackWidgetKit", targets: ["BartTrackWidgetKit"])
    ],
    targets: [
        .target(name: "BartTrackCore"),
        .target(name: "BartTrackWidgetUI", dependencies: ["BartTrackCore"]),
        .target(name: "BartTrackWidgetKit", dependencies: ["BartTrackCore", "BartTrackWidgetUI"]),
        .testTarget(name: "BartTrackCoreTests", dependencies: ["BartTrackCore"]),
        .testTarget(name: "BartTrackWidgetUITests", dependencies: ["BartTrackCore", "BartTrackWidgetUI"]),
        .testTarget(name: "BartTrackWidgetKitTests", dependencies: ["BartTrackWidgetKit"])
    ]
)
