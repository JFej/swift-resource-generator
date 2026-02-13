// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swift-resource-generator",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
    .watchOS(.v9),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "ResourceGenerator",
      targets: ["ResourceGenerator"]
    )
  ],
  targets: [
    .target(
      name: "ResourceGenerator",
      path: "Sources/ResourceGenerator"
    ),
    .testTarget(
      name: "ResourceGeneratorTests",
      dependencies: ["ResourceGenerator"],
      path: "Tests/ResourceGeneratorTests"
    ),
  ]
)
