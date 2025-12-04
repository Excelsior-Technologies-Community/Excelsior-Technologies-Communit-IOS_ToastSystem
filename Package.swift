// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ToastSystem",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "ToastSystem",
            targets: ["ToastSystem"]
        )
    ],
    targets: [
        .target(
            name: "ToastSystem",
            path: "Sources/ToastSystem"
        )
    ]
)


