# ``ResourceGenerator``

@Metadata {
  @DisplayName("ResourceGenerator")
}

Generate Apple resource files (starting with `.xcassets`) using a Swift DSL.

## Overview

`ResourceGenerator` models resources as typed Swift values, validates them, and writes deterministic file output.

Use it to:

- Generate complete asset catalogs programmatically.
- Validate resource definitions before writing.
- Preview changes with plan + diff APIs.
- Parse existing `.xcassets` trees back into typed models.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:AssetCatalogDSL>
- <doc:ParsingAndImporting>
- <doc:ErrorHandling>

### Core Generation API

- ``ResourcePackage``
- ``Resource``
- ``ResourceBuilder``
- ``GenerationPlan``
- ``ResourceDiff``
- ``ResourceWriteReport``
- ``ResourceWriteOptions``
- ``ResourceWriteMode``

### Asset Catalog Model

- ``AssetCatalog``
- ``AssetNode``
- ``AssetGroup``
- ``AssetImageSet``
- ``AssetColorSet``
- ``AssetDataSet``
- ``AssetSymbolSet``
- ``AssetAppIconSet``

### DSL Helpers

- ``Group(_:_:)``
- ``ImageSet(_:filename:source:idiom:scale:appearances:)``
- ``ImageSet(_:_:)``
- ``ImageVariant(filename:source:idiom:scale:appearances:)``
- ``ColorSet(_:red:green:blue:alpha:appearances:)``
- ``DataSet(_:files:)``
- ``DataFile(filename:source:idiom:universalTypeIdentifier:)``
- ``SymbolSet(_:files:)``
- ``SymbolFile(filename:source:)``
- ``AppIconSet(_:icons:)``
- ``AppIcon(filename:source:idiom:size:scale:platform:)``

### Parsing and Plugins

- ``AssetCatalogParser``
- ``AssetCatalogImportPlugin``
- ``ResourcePlugin``
- ``ResourcePluginRegistry``
- ``ResourcePluginRegistryError``

### Error Types

- ``ResourceGeneratorError``
- ``ParseErrorContext``
- ``ValidationErrorContext``
- ``WriteErrorContext``
- ``ParseAssetKind``
- ``ValidationErrorReason``
- ``WriteErrorReason``
