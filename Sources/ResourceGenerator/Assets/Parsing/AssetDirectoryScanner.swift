import Foundation

/// Filesystem helpers used by the asset parser.
enum AssetDirectoryScanner {
  /// Returns non-hidden child directories excluding `Contents.json`.
  static func childDirectories(
    in directory: URL, catalogURL: URL
  ) throws(ResourceGeneratorError)
    -> [URL]
  {
    do {
      return try FileManager.default
        .contentsOfDirectory(
          at: directory,
          includingPropertiesForKeys: [.isDirectoryKey],
          options: [.skipsHiddenFiles]
        )
        .filter { item in
          item.lastPathComponent != "Contents.json"
        }
        .filter { item in
          (try? item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
        }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    } catch {
      throw ResourceGeneratorError.parse(
        .init(
          catalogPath: catalogURL.path,
          nodePath: directory.path,
          assetKind: .group,
          underlyingErrorDescription: String(describing: error)
        )
      )
    }
  }
}
