// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LangCar",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "LangCar",
            targets: ["LangCar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "LangCar",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            resources: [
                .process("Resources"),
                .process("Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "LangCarTests",
            dependencies: ["LangCar"]
        ),
    ]
)
