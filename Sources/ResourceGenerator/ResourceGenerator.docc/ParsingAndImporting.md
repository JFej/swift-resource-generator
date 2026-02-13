# Parsing and Importing

`ResourceGenerator` can parse existing `.xcassets` directories back into typed models.

## Parse a catalog directly

```swift
import Foundation
import ResourceGenerator

let catalogURL = URL(fileURLWithPath: "/tmp/AppAssets.xcassets")
let catalog = try AssetCatalogParser.parseCatalog(at: catalogURL)
```

Unknown child directories are parsed as ``AssetGroup`` so catalogs remain robust when custom folder structures are present.

## Use the import plugin

```swift
let plugin = AssetCatalogImportPlugin(catalogPaths: [catalogURL])

var registry = ResourcePluginRegistry()
registry.register(plugin)

let importedResources = try registry.resources(for: plugin.key)
let importedPackage = ResourcePackage { importedResources }
```

This plugin-based flow lets you merge imported resources with generated resources in a single package.
