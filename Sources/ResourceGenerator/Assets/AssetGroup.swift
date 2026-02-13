import Foundation

/// Folder node inside an asset catalog.
public struct AssetGroup: AssetNode, Sendable {
  /// Group name.
  public let name: String
  private let children: [any AssetNode]

  /// Creates a group with nested asset nodes.
  public init(_ name: String, @AssetBuilder _ content: () -> [any AssetNode]) {
    self.name = name
    self.children = content()
  }

  /// Validates group name, child uniqueness, and child validity.
  public func validate(in parentPath: String) throws(ResourceGeneratorError) {
    let path = "\(parentPath)/\(name)"
    try ResourceValidator.validateName(name, at: path)

    var seen = Set<String>()
    for child in children {
      if !seen.insert(child.name).inserted {
        throw ResourceGeneratorError.validation(
          .init(path: "\(path)/\(child.name)", reason: .duplicatePath)
        )
      }

      try child.validate(in: path)
    }
  }

  /// Generates group directory, `Contents.json`, and all child entries.
  public func generateEntries(
    in parentPath: String
  ) throws(ResourceGeneratorError)
    -> [GeneratedEntry]
  {
    let groupPath = "\(parentPath)/\(name)"
    var entries: [GeneratedEntry] = [
      .directory(groupPath),
      .file(
        "\(groupPath)/Contents.json",
        try AssetCatalogJSON.encode(
          AssetCatalogRootContents(info: AssetCatalogJSON.info),
          for: "\(groupPath)/Contents.json"
        )
      ),
    ]

    for child in children {
      entries.append(contentsOf: try child.generateEntries(in: groupPath))
    }

    return entries
  }
}
