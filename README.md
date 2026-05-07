# swift-resource-generator

[![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FJFej%2Fswift-resource-generator%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/JFej/swift-resource-generator)
[![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FJFej%2Fswift-resource-generator%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/JFej/swift-resource-generator)

[Documentation](https://swiftpackageindex.com/JFej/swift-resource-generator/documentation)

Generate Apple resource files with a readable Swift DSL.

Package name: `swift-resource-generator`  
Import/module name: `ResourceGenerator`

## Versioning

This package follows semantic versioning.

- `0.x` (current phase): breaking changes are expected.
- `1.0.0+`: breaking changes only on major versions.

Current baseline tag: `0.1.0`.

## Compatibility

- Swift tools: `6.2+`
- Platforms:
  - macOS 13+
  - iOS 16+
  - tvOS 16+
  - watchOS 9+
  - visionOS 1+

## Main API

- `ResourcePackage` -> plan, diff, write, validate
- `AssetCatalog` -> `.xcassets` root
- `Group`, `ImageSet`, `ColorSet`, `DataSet`, `SymbolSet`, `AppIconSet`
- `DataFile`, `SymbolFile`, `AppIcon` helper builders
- `AssetCatalogParser` -> parse existing catalogs
- `AssetCatalogImportPlugin` -> plugin-based import flow
- Unified errors: `ResourceGeneratorError` (`.parse`, `.validation`, `.write`)

## Example

```swift
import Foundation
import ResourceGenerator

let package = ResourcePackage {
  AssetCatalog("AppAssets") {
    ImageSet("Hero") {
      ImageVariant(
        filename: "hero-light.png",
        source: .file(URL(fileURLWithPath: "/tmp/hero-light.png")),
        scale: .x2,
        appearances: [.luminosity(.light)]
      )
      ImageVariant(
        filename: "hero-dark.png",
        source: .file(URL(fileURLWithPath: "/tmp/hero-dark.png")),
        scale: .x2,
        appearances: [.luminosity(.dark)]
      )
    }

    ColorSet("Primary", red: 0.2, green: 0.4, blue: 0.6)

    DataSet(
      "Payload",
      files: [
        DataFile(filename: "data.json", source: .data(Data("{}".utf8)), universalTypeIdentifier: "public.json")
      ]
    )

    SymbolSet(
      "Plus",
      files: [
        SymbolFile(filename: "plus.svg", source: .file(URL(fileURLWithPath: "/tmp/plus.svg")))
      ]
    )

    AppIconSet(
      "AppIcon",
      icons: [
        AppIcon(filename: "app_icon.png", source: .file(URL(fileURLWithPath: "/tmp/app_icon.png")), idiom: .universal, size: "1024x1024")
      ]
    )
  }
}

let report = try package.write(
  to: URL(fileURLWithPath: "/tmp/generated"),
  options: .init(mode: .mergePreferGenerated)
)

print(report.diff.createdFiles)
```
