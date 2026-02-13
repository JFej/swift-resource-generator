import Foundation

/// Plugin that imports existing `.xcassets` folders as ``AssetCatalog`` resources.
public struct AssetCatalogImportPlugin: ResourcePlugin {
  /// Registry key used to resolve this plugin.
  public let key: String
  /// Catalog locations to parse.
  public let catalogPaths: [URL]

  /// Creates an import plugin.
  ///
  /// - Parameters:
  ///   - key: Registry key for lookup.
  ///   - catalogPaths: Paths to existing `.xcassets` directories.
  public init(key: String = "assetCatalog.import", catalogPaths: [URL]) {
    self.key = key
    self.catalogPaths = catalogPaths
  }

  /// Parses configured catalog paths into resources.
  public func makeResources() throws(ResourceGeneratorError) -> [any Resource] {
    var resources: [any Resource] = []
    for path in catalogPaths {
      resources.append(try AssetCatalogParser.parseCatalog(at: path))
    }
    return resources
  }
}
