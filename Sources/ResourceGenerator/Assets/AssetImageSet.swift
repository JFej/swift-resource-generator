import Foundation

/// Common source for binary files copied into a generated asset catalog.
public enum AssetFileSource: Sendable {
  /// Inline bytes.
  case data(Data)
  /// Source file loaded from disk during generation.
  case file(URL)

  /// Resolves the source into bytes.
  func load() throws(ResourceGeneratorError) -> Data {
    switch self {
      case .data(let data):
        return data
      case .file(let url):
        guard url.isFileURL else {
          throw ResourceGeneratorError.validation(
            .init(
              path: url.absoluteString,
              reason: .invalidAssetConfiguration,
              details: "only file URLs are supported for AssetFileSource.file"
            )
          )
        }

        do {
          return try Data(contentsOf: url)
        } catch {
          throw ResourceGeneratorError.validation(
            .init(
              path: url.path,
              reason: .invalidAssetConfiguration,
              details: "failed to read source file: \(String(describing: error))"
            )
          )
        }
    }
  }
}

/// Supported xcassets idiom values.
public enum AssetIdiom: String, Codable, Sendable {
  case universal
  case iphone
  case ipad
  case mac
  case tv
  case watch
}

/// Supported image scale values.
public enum AssetScale: String, Codable, Sendable {
  case x1 = "1x"
  case x2 = "2x"
  case x3 = "3x"
}

/// `.imageset` node model.
public struct AssetImageSet: AssetNode, Sendable {
  /// Metadata entry written to `Contents.json`.
  public struct Variant: Encodable, Sendable {
    /// Image file name relative to the imageset folder.
    public let filename: String
    /// Device idiom this variant targets.
    public let idiom: AssetIdiom
    /// Scale this variant targets.
    public let scale: AssetScale
    /// Optional appearance filters (dark mode, high contrast, ...).
    public let appearances: [AssetAppearance]?

    /// Creates image metadata.
    public init(
      filename: String,
      idiom: AssetIdiom = .universal,
      scale: AssetScale = .x1,
      appearances: [AssetAppearance]? = nil
    ) {
      self.filename = filename
      self.idiom = idiom
      self.scale = scale
      self.appearances = appearances
    }
  }

  /// Binds metadata to a concrete file source.
  public struct VariantSource: Sendable {
    /// Metadata to encode.
    public let variant: Variant
    /// Binary source for the variant file.
    public let source: AssetFileSource

    /// Creates a bound image variant.
    public init(variant: Variant, source: AssetFileSource) {
      self.variant = variant
      self.source = source
    }
  }

  /// Alias kept for call-site readability.
  public typealias Source = AssetFileSource

  private struct ContentsFile: Encodable, Sendable {
    let images: [Variant]
    let info: AssetCatalogInfo
  }

  /// Logical asset name without `.imageset`.
  public let name: String
  private let variants: [VariantSource]

  /// Creates an image set from tuple-based variant/source pairs.
  public init(_ name: String, variants: [(Variant, AssetFileSource)]) {
    self.name = name
    self.variants = variants.map { VariantSource(variant: $0.0, source: $0.1) }
  }

  /// Creates an image set using ``ImageVariantBuilder``.
  public init(_ name: String, @ImageVariantBuilder _ variants: () -> [VariantSource]) {
    self.name = name
    self.variants = variants()
  }

  /// Convenience constructor for a single-file image set.
  public static func single(
    _ name: String,
    filename: String,
    source: AssetFileSource,
    idiom: AssetIdiom = .universal,
    scale: AssetScale = .x1,
    appearances: [AssetAppearance]? = nil
  ) -> AssetImageSet {
    AssetImageSet(
      name,
      variants: [
        (
          .init(filename: filename, idiom: idiom, scale: scale, appearances: appearances),
          source,
        )
      ]
    )
  }

  /// Validates set name and non-empty variants.
  public func validate(in parentPath: String) throws(ResourceGeneratorError) {
    let path = "\(parentPath)/\(name)"
    try ResourceValidator.validateName(name, at: path)

    guard !variants.isEmpty else {
      throw ResourceValidator.invalidAssetConfiguration(
        path: path,
        details: "expects at least one image variant"
      )
    }
  }

  /// Generates the `.imageset` directory, `Contents.json`, and image files.
  public func generateEntries(
    in parentPath: String
  ) throws(ResourceGeneratorError)
    -> [GeneratedEntry]
  {
    let setPath = "\(parentPath)/\(name).imageset"
    var entries: [GeneratedEntry] = [.directory(setPath)]

    let metadata = variants.map(\.variant)
    let contents = try AssetCatalogJSON.encode(
      ContentsFile(images: metadata, info: AssetCatalogJSON.info),
      for: "\(setPath)/Contents.json"
    )
    entries.append(.file("\(setPath)/Contents.json", contents))

    for entry in variants {
      entries.append(.file("\(setPath)/\(entry.variant.filename)", try entry.source.load()))
    }

    return entries
  }
}
