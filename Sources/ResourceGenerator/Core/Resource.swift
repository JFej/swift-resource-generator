import Foundation

/// Contract for any resource type that can emit generated filesystem entries.
public protocol Resource: Sendable {
  /// Materializes all entries for this resource.
  ///
  /// - Returns: Directories and files relative to the chosen output path.
  /// - Throws: ``ResourceGeneratorError`` when generation fails.
  func generateEntries() throws(ResourceGeneratorError) -> [GeneratedEntry]
}
