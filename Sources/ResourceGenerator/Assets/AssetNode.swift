import Foundation

/// Node inside an asset catalog tree.
public protocol AssetNode: Sendable {
  /// Node name without extension (except groups).
  var name: String { get }
  /// Validates node configuration in its parent scope.
  func validate(in parentPath: String) throws(ResourceGeneratorError)
  /// Generates all directory/file entries for this node.
  func generateEntries(in parentPath: String) throws(ResourceGeneratorError) -> [GeneratedEntry]
}

extension AssetNode {
  /// Default name validation for simple nodes.
  public func validate(in parentPath: String) throws(ResourceGeneratorError) {
    try ResourceValidator.validateName(name, at: "\(parentPath)/\(name)")
  }
}
