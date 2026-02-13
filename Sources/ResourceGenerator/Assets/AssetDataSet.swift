import Foundation

/// `.dataset` node model.
public struct AssetDataSet: AssetNode, Sendable {
  /// Metadata entry written into `Contents.json`.
  public struct Entry: Encodable, Sendable {
    /// Data file name.
    public let filename: String
    /// Device idiom this data file applies to.
    public let idiom: AssetIdiom
    /// Optional UTI string for Xcode metadata.
    public let universalTypeIdentifier: String?

    enum CodingKeys: String, CodingKey {
      case filename
      case idiom
      case universalTypeIdentifier = "universal-type-identifier"
    }

    /// Creates dataset metadata entry.
    public init(
      filename: String,
      idiom: AssetIdiom = .universal,
      universalTypeIdentifier: String? = nil
    ) {
      self.filename = filename
      self.idiom = idiom
      self.universalTypeIdentifier = universalTypeIdentifier
    }
  }

  /// Binds dataset metadata to a concrete file source.
  public struct File: Sendable {
    /// Metadata to encode.
    public let metadata: Entry
    /// Binary source for the dataset file.
    public let source: AssetFileSource

    /// Creates a dataset file binding.
    public init(metadata: Entry, source: AssetFileSource) {
      self.metadata = metadata
      self.source = source
    }
  }

  private struct ContentsFile: Encodable, Sendable {
    let data: [Entry]
    let info: AssetCatalogInfo
  }

  /// Logical asset name without `.dataset`.
  public let name: String
  private let files: [File]

  /// Creates a data set from file bindings.
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
        details: "expects at least one dataset file"
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

  /// Generates the `.dataset` directory, `Contents.json`, and data files.
  public func generateEntries(
    in parentPath: String
  ) throws(ResourceGeneratorError)
    -> [GeneratedEntry]
  {
    let setPath = "\(parentPath)/\(name).dataset"
    var generated: [GeneratedEntry] = [
      .directory(setPath),
      .file(
        "\(setPath)/Contents.json",
        try AssetCatalogJSON.encode(
          ContentsFile(data: files.map(\.metadata), info: AssetCatalogJSON.info),
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
