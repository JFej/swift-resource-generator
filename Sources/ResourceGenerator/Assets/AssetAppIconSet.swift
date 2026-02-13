import Foundation

/// Supported app-icon platform values.
public enum AssetPlatform: String, Codable, Sendable {
  /// iOS.
  case ios
  /// macOS.
  case macOS = "macos"
  /// tvOS.
  case tvOS = "tvos"
  /// watchOS.
  case watchOS = "watchos"
  /// visionOS.
  case visionOS = "visionos"
}

/// `.appiconset` node model.
public struct AssetAppIconSet: AssetNode, Sendable {
  /// Metadata entry written into `Contents.json`.
  public struct Entry: Encodable, Sendable {
    /// Optional icon filename.
    public let filename: String?
    /// Device idiom for this icon slot.
    public let idiom: AssetIdiom
    /// Icon size string (for example `1024x1024`).
    public let size: String
    /// Optional icon scale.
    public let scale: AssetScale?
    /// Optional target platform.
    public let platform: AssetPlatform?

    /// Creates app icon metadata and normalizes special 1024x1024 iOS case.
    public init(
      filename: String?,
      idiom: AssetIdiom,
      size: String,
      scale: AssetScale? = .x1,
      platform: AssetPlatform? = nil
    ) {
      let normalizedSize = size.replacingOccurrences(of: " ", with: "")
      let resolvedPlatform =
        platform ?? (idiom == .universal && normalizedSize == "1024x1024" ? .ios : nil)
      let omitScale =
        idiom == .universal && normalizedSize == "1024x1024"
        && resolvedPlatform == .ios

      self.filename = filename
      self.idiom = idiom
      self.size = size
      self.scale = omitScale ? nil : scale
      self.platform = resolvedPlatform
    }
  }

  /// Binds app icon metadata to an optional file source.
  public struct Icon: Sendable {
    /// Metadata to encode.
    public let metadata: Entry
    /// File source when `metadata.filename` is present.
    public let source: AssetFileSource?

    /// Creates an app icon binding.
    public init(metadata: Entry, source: AssetFileSource?) {
      self.metadata = metadata
      self.source = source
    }
  }

  private struct ContentsFile: Encodable, Sendable {
    let images: [Entry]
    let info: AssetCatalogInfo
  }

  /// Logical asset name without `.appiconset`.
  public let name: String
  private let icons: [Icon]

  /// Creates an app icon set from icon bindings.
  public init(_ name: String, icons: [Icon]) {
    self.name = name
    self.icons = icons
  }

  /// Validates name, required icons, and filename/source consistency.
  public func validate(in parentPath: String) throws(ResourceGeneratorError) {
    let path = "\(parentPath)/\(name)"
    try ResourceValidator.validateName(name, at: path)

    guard !icons.isEmpty else {
      throw ResourceValidator.invalidAssetConfiguration(
        path: path,
        details: "expects at least one icon entry"
      )
    }

    var seenFilenames = Set<String>()

    for icon in icons {
      let filename = icon.metadata.filename
      switch (filename, icon.source) {
        case (.some, .none):
          throw ResourceValidator.invalidAssetConfiguration(
            path: path,
            details: "icon '\(filename!)' requires a source"
          )
        case (.none, .some):
          throw ResourceValidator.invalidAssetConfiguration(
            path: path,
            details: "icon without filename cannot have source"
          )
        case (.some(let name), .some):
          if !seenFilenames.insert(name).inserted {
            throw ResourceValidator.invalidAssetConfiguration(
              path: path,
              details: "duplicate filename '\(name)'"
            )
          }
        case (.none, .none):
          continue
      }
    }
  }

  /// Generates the `.appiconset` directory, `Contents.json`, and icon files.
  public func generateEntries(
    in parentPath: String
  ) throws(ResourceGeneratorError)
    -> [GeneratedEntry]
  {
    let setPath = "\(parentPath)/\(name).appiconset"
    var generated: [GeneratedEntry] = [
      .directory(setPath),
      .file(
        "\(setPath)/Contents.json",
        try AssetCatalogJSON.encode(
          ContentsFile(images: icons.map(\.metadata), info: AssetCatalogJSON.info),
          for: "\(setPath)/Contents.json"
        )
      ),
    ]

    for icon in icons {
      if let filename = icon.metadata.filename, let source = icon.source {
        generated.append(.file("\(setPath)/\(filename)", try source.load()))
      }
    }

    return generated
  }
}
