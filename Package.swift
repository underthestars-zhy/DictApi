// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DictApi",
    platforms: [
        .watchOS(.v8),
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DictApi",
            targets: ["DictApi"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "Sentry", url: "https://github.com/getsentry/sentry-cocoa", from: "7.2.3"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4"),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DictApi",
            dependencies: [
                .product(name: "Sentry", package: "Sentry"),
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "ObjectMapper", package: "ObjectMapper"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
            ]),
        .testTarget(
            name: "DictApiTests",
            dependencies: ["DictApi"]),
    ]
)
