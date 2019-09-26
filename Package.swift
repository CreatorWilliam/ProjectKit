// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectKit",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ProjectKit",
            type: .dynamic,
            targets: ["ApplicationKit",
                      "ComponentKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "https://github.com/CreatorWilliam/JSONKit.git", Package.Dependency.Requirement.branch("master")),
      .package(url: "https://github.com/CreatorWilliam/LayoutKit.git", Package.Dependency.Requirement.branch("master")),
      .package(url: "https://github.com/CreatorWilliam/NetworkKit.git", Package.Dependency.Requirement.branch("master")),
      .package(url: "https://github.com/CreatorWilliam/ImageKit.git", Package.Dependency.Requirement.branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ApplicationKit",
            dependencies: ["LayoutKit",
                           "JSONKit",
                           "NetworkKit"]),
        .target(name: "ComponentKit",
                dependencies: ["ApplicationKit", "ImageKit"]),
        .testTarget(
            name: "ApplicationKitTests",
            dependencies: ["ApplicationKit"]),
    ]
)
