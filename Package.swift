// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let urlRequestHandler: Self = "URLRequestHandler"
}

extension Target.Dependency {
    static var urlRequestHandler: Self { .target(name: .urlRequestHandler) }
}

extension Target.Dependency {
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var issueReporting: Self { .product(name: "IssueReporting", package: "xctest-dynamic-overlay") }
    static var loggingExtras: Self { .product(name: "LoggingExtras", package: "swift-logging-extras") }
}

let package = Package(
    name: "swift-urlrequest-handler",
    platforms: [
      .iOS(.v13),
      .macOS(.v10_15),
      .tvOS(.v13),
      .watchOS(.v6)
    ],
    products: [
        .library(name: .urlRequestHandler, targets: [.urlRequestHandler])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.10.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.4.3"),
        .package(url: "https://github.com/coenttb/swift-logging-extras", from: "0.0.1")
    ],
    targets: [
        .target(
            name: .urlRequestHandler,
            dependencies: [
                .dependencies,
                .issueReporting,
                .loggingExtras
            ]
        ),
        .testTarget(
            name: .urlRequestHandler.tests,
            dependencies: [
                .urlRequestHandler,
                .dependenciesTestSupport
            ]
        )
    ]
)

extension String { var tests: Self { self + " Tests" } }