// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MMDatabase",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MMDatabase", targets: ["MMDatabase"])
    ],
    dependencies: [
        .package(url: "https://github.com/Tencent/wcdb", .upToNextMajor(from: "2.1.11"))
    ],
    targets: [
        .target(name: "MMDatabase", dependencies: [
            .product(name: "WCDBSwift", package: "wcdb")
        ]),
        .testTarget( name: "MMDatabaseTests", dependencies: ["MMDatabase"])
    ]
)
