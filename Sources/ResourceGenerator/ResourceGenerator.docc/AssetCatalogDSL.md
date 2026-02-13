# Asset Catalog DSL

The DSL is built from global helper functions that produce strongly typed asset nodes.

## Root and grouping

- Use ``AssetCatalog`` as the root `.xcassets` resource.
- Use ``Group(_:_:)`` to create folder groupings.

```swift
let catalog = AssetCatalog("AppAssets") {
  Group("Marketing") {
    ImageSet("Banner", filename: "banner@2x.png", source: .file(URL(fileURLWithPath: "/tmp/banner@2x.png")), scale: .x2)
  }
}
```

## Images

Use either the single-file helper or the variant builder.

```swift
ImageSet("Logo") {
  ImageVariant(
    filename: "logo-light.png",
    source: .file(URL(fileURLWithPath: "/tmp/logo-light.png")),
    appearances: [.luminosity(.light)]
  )
  ImageVariant(
    filename: "logo-dark.png",
    source: .file(URL(fileURLWithPath: "/tmp/logo-dark.png")),
    appearances: [.luminosity(.dark)]
  )
}
```

## Colors

Use ``ColorSet(_:red:green:blue:alpha:appearances:)`` for one color entry, or instantiate ``AssetColorSet`` directly for advanced cases.

## Data and symbols

Use explicit file models instead of tuples:

```swift
DataSet(
  "Payload",
  files: [
    DataFile(filename: "payload.json", source: .data(Data("{}".utf8)), universalTypeIdentifier: "public.json")
  ]
)

SymbolSet(
  "Plus",
  files: [
    SymbolFile(filename: "plus.svg", source: .file(URL(fileURLWithPath: "/tmp/plus.svg")))
  ]
)
```

## App icons

Use `AppIcon` entries with optional source when filename is omitted.

```swift
AppIconSet(
  "AppIcon",
  icons: [
    AppIcon(
      filename: "app_icon.png",
      source: .file(URL(fileURLWithPath: "/tmp/app_icon.png")),
      idiom: .universal,
      size: "1024x1024"
    )
  ]
)
```

Validation rules enforce:

- Non-empty sets where required.
- Unique filenames in data/symbol/icon sets.
- `AppIcon` filename/source consistency.
- ``AssetFileSource/file(_:)`` accepts only `file://` URLs.
