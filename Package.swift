// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "DiffedAssertEqual",
    products: [
        .library(
            name: "DiffedAssertEqual",
            targets: ["DiffedAssertEqual"]
        ),
    ],
    targets: [
        .target(
            name: "DiffedAssertEqual",
            dependencies: []
        ),
        .testTarget(
            name: "DiffedAssertEqualTests",
            dependencies: ["DiffedAssertEqual"]
        ),
    ]
)
