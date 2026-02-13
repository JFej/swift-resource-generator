import Foundation

/// Creates an ``AssetGroup``.
public func Group(_ name: String, @AssetBuilder _ content: () -> [any AssetNode]) -> AssetGroup {
  AssetGroup(name, content)
}

/// Creates an image variant binding for ``AssetImageSet``.
public func ImageVariant(
  filename: String,
  source: AssetFileSource,
  idiom: AssetIdiom = .universal,
  scale: AssetScale = .x1,
  appearances: [AssetAppearance]? = nil
) -> AssetImageSet.VariantSource {
  .init(
    variant: .init(filename: filename, idiom: idiom, scale: scale, appearances: appearances),
    source: source
  )
}

/// Creates a single-variant ``AssetImageSet``.
public func ImageSet(
  _ name: String,
  filename: String,
  source: AssetFileSource,
  idiom: AssetIdiom = .universal,
  scale: AssetScale = .x1,
  appearances: [AssetAppearance]? = nil
) -> AssetImageSet {
  .single(
    name,
    filename: filename,
    source: source,
    idiom: idiom,
    scale: scale,
    appearances: appearances
  )
}

/// Creates a multi-variant ``AssetImageSet`` using ``ImageVariantBuilder``.
public func ImageSet(
  _ name: String,
  @ImageVariantBuilder _ variants: () -> [AssetImageSet.VariantSource]
) -> AssetImageSet {
  AssetImageSet(name, variants)
}

/// Creates a single-entry ``AssetColorSet``.
public func ColorSet(
  _ name: String,
  red: Double,
  green: Double,
  blue: Double,
  alpha: Double = 1.0,
  appearances: [AssetAppearance]? = nil
) -> AssetColorSet {
  .single(
    name,
    red: red,
    green: green,
    blue: blue,
    alpha: alpha,
    appearances: appearances
  )
}

/// Creates a dataset file binding for ``AssetDataSet``.
public func DataFile(
  filename: String,
  source: AssetFileSource,
  idiom: AssetIdiom = .universal,
  universalTypeIdentifier: String? = nil
) -> AssetDataSet.File {
  .init(
    metadata: .init(
      filename: filename,
      idiom: idiom,
      universalTypeIdentifier: universalTypeIdentifier
    ),
    source: source
  )
}

/// Creates an ``AssetDataSet``.
public func DataSet(_ name: String, files: [AssetDataSet.File]) -> AssetDataSet {
  AssetDataSet(name, files: files)
}

/// Creates a symbol file binding for ``AssetSymbolSet``.
public func SymbolFile(filename: String, source: AssetFileSource) -> AssetSymbolSet.File {
  .init(metadata: .init(filename: filename), source: source)
}

/// Creates an ``AssetSymbolSet``.
public func SymbolSet(_ name: String, files: [AssetSymbolSet.File]) -> AssetSymbolSet {
  AssetSymbolSet(name, files: files)
}

/// Creates an app icon binding for ``AssetAppIconSet``.
public func AppIcon(
  filename: String?,
  source: AssetFileSource? = nil,
  idiom: AssetIdiom,
  size: String,
  scale: AssetScale? = .x1,
  platform: AssetPlatform? = nil
) -> AssetAppIconSet.Icon {
  .init(
    metadata: .init(filename: filename, idiom: idiom, size: size, scale: scale, platform: platform),
    source: source
  )
}

/// Creates an ``AssetAppIconSet``.
public func AppIconSet(_ name: String, icons: [AssetAppIconSet.Icon]) -> AssetAppIconSet {
  AssetAppIconSet(name, icons: icons)
}
