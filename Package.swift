// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ToastSystem",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ToastSystem",
            targets: ["ToastSystem"]
        ),
    ],
    targets: [
        .target(
            name: "ToastSystem",
            path: "Sources/ToastSystem"
        ),
        .testTarget(
            name: "ToastSystemTests",
            dependencies: ["ToastSystem"],
            path: "Tests/ToastSystemTests"
        ),
    ]
)
