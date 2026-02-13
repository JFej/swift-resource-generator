import Foundation

/// A single `.xcassets` catalog resource.
public struct AssetCatalog: Resource, Sendable {
  private let name: String
  private let nodes: [any AssetNode]

  /// Catalog folder name including `.xcassets`.
  public var catalogName: String { name }

  /// Creates an asset catalog.
  ///
  /// If `name` does not end with `.xcassets`, the suffix is appended automatically.
  public init(_ name: String, @AssetBuilder _ content: () -> [any AssetNode] = { [] }) {
    self.name = name.hasSuffix(".xcassets") ? name : "\(name).xcassets"
    self.nodes = content()
  }

  /// Validates catalog name, unique top-level node names, and all child nodes.
  public func validate() throws(ResourceGeneratorError) {
    let catalogPath = name.replacingOccurrences(of: ".xcassets", with: "")
    try ResourceValidator.validateName(catalogPath, at: name)

    var seen = Set<String>()
    for node in nodes {
      if !seen.insert(node.name).inserted {
        throw ResourceGeneratorError.validation(
          .init(path: "\(name)/\(node.name)", reason: .duplicatePath)
        )
      }

      try node.validate(in: name)
    }
  }

  /// Generates catalog directory, root `Contents.json`, and all node entries.
  public func generateEntries() throws(ResourceGeneratorError) -> [GeneratedEntry] {
    var entries: [GeneratedEntry] = [
      .directory(name),
      .file(
        "\(name)/Contents.json",
        try AssetCatalogJSON.encode(
          AssetCatalogRootContents(info: AssetCatalogJSON.info),
          for: "\(name)/Contents.json"
        )
      ),
    ]

    for node in nodes {
      entries.append(contentsOf: try node.generateEntries(in: name))
    }

    return entries
  }
}

extension AssetCatalog: ResourceValidating {}
