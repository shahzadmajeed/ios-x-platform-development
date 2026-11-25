// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "GamingApp",
    platforms: [.iOS(.v17)],
    products: [
        // xtool packages the single library product as the iOS app.
        .library(name: "GamingApp", targets: ["GamingApp"]),
    ],
    dependencies: [
        .package(name: "GamingUI", path: "../.."),
    ],
    targets: [
        .target(
            name: "GamingApp",
            dependencies: [
                .product(name: "GamingPreview", package: "GamingUI"),
            ]
        ),
    ]
)
