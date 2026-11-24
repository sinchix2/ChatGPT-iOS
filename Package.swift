// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChatGPT-iOS",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ChatGPTCore",
            targets: ["ChatGPTCore"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ChatGPTCore",
            path: ".",
            exclude: [
                "Resources/Info.plist"
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
