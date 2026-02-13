import Foundation

/// `.symbolset` node model.
public struct AssetSymbolSet: AssetNode, Sendable {
  /// Metadata entry written into `Contents.json`.
  public struct Entry: Encodable, Sendable {
    /// Symbol file name.
    public let filename: String

    /// Creates symbol metadata entry.
    public init(filename: String) {
      self.filename = filename
    }
  }

  /// Binds symbol metadata to a concrete file source.
  public struct File: Sendable {
    /// Metadata to encode.
    public let metadata: Entry
    /// Binary source for the symbol file.
    public let source: AssetFileSource

    /// Creates a symbol file binding.
    public init(metadata: Entry, source: AssetFileSource) {
      self.metadata = metadata
      self.source = source
    }
  }

  private struct ContentsFile: Encodable, Sendable {
    let symbols: [Entry]
    let info: AssetCatalogInfo
  }

  /// Logical asset name without `.symbolset`.
  public let name: String
  private let files: [File]

  /// Creates a symbol set from file bindings.
  public init(_ name: String, files: [File]) {
    self.name = name
    self.files = files
  }

  /// Validates name, required files, and unique filenames.
  public func validate(in parentPath: String) throws(ResourceGeneratorError) {
    let path = "\(parentPath)/\(name)"
    try ResourceValidator.validateName(name, at: path)

    guard !files.isEmpty else {
      throw ResourceValidator.invalidAssetConfiguration(
        path: path,
        details: "expects at least one symbol file"
      )
    }

    var seenFilenames = Set<String>()
    for file in files {
      if !seenFilenames.insert(file.metadata.filename).inserted {
        throw ResourceValidator.invalidAssetConfiguration(
          path: path,
          details: "duplicate filename '\(file.metadata.filename)'"
        )
      }
    }
  }

  /// Generates the `.symbolset` directory, `Contents.json`, and symbol files.
  public func generateEntries(
    in parentPath: String
  ) throws(ResourceGeneratorError)
    -> [GeneratedEntry]
  {
    let setPath = "\(parentPath)/\(name).symbolset"
    var generated: [GeneratedEntry] = [
      .directory(setPath),
      .file(
        "\(setPath)/Contents.json",
        try AssetCatalogJSON.encode(
          ContentsFile(symbols: files.map(\.metadata), info: AssetCatalogJSON.info),
          for: "\(setPath)/Contents.json"
        )
      ),
    ]

    for file in files {
      generated.append(.file("\(setPath)/\(file.metadata.filename)", try file.source.load()))
    }

    return generated
  }
}
