// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BartTrack",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "BartTrackCore", targets: ["BartTrackCore"])
    ],
    targets: [
        .target(name: "BartTrackCore"),
        .testTarget(name: "BartTrackCoreTests", dependencies: ["BartTrackCore"])
    ]
)
