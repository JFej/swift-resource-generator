# Getting Started

Create a `ResourcePackage`, compose one or more resources, then `plan`, `diff`, or `write`.

## Create a package

```swift
import Foundation
import ResourceGenerator

let package = ResourcePackage {
  AssetCatalog("AppAssets") {
    ImageSet(
      "Hero",
      filename: "hero.png",
      source: .file(URL(fileURLWithPath: "/tmp/hero.png")),
      idiom: .universal,
      scale: .x2
    )

    ColorSet("Brand", red: 0.15, green: 0.55, blue: 0.85)
  }
}
```

## Validate and preview

```swift
try package.validate()

let output = URL(fileURLWithPath: "/tmp/generated")
let diff = try package.diff(against: output)
print(diff.createdFiles)
```

## Write to disk

```swift
let report = try package.write(
  to: output,
  options: .init(mode: .mergePreferGenerated)
)

print(report.writtenFilesCount)
```

## Next steps

- Use <doc:AssetCatalogDSL> for all supported asset node types.
- Use <doc:ParsingAndImporting> to round-trip existing catalogs.
- Use <doc:ErrorHandling> to handle typed errors.
