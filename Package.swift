// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "GamingUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "GamingUI", targets: ["GamingUI"]),
        .library(name: "GamingPreview", targets: ["GamingPreview"]),
    ],
    targets: [
        .target(name: "GamingUI"),
        .target(name: "GamingPreview", dependencies: ["GamingUI"]),
        .testTarget(name: "GamingUITests", dependencies: ["GamingUI", "GamingPreview"]),
    ]
)
