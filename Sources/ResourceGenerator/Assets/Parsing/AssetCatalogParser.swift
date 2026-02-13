import Foundation

/// Facade for parsing an existing `.xcassets` directory into ``AssetCatalog``.
public enum AssetCatalogParser {
  /// Parses a catalog directory recursively.
  ///
  /// Unknown directory extensions are parsed as ``AssetGroup`` nodes.
  public static func parseCatalog(
    at catalogURL: URL
  ) throws(ResourceGeneratorError)
    -> AssetCatalog
  {
    let folderName = catalogURL.lastPathComponent
    let catalogName = folderName.hasSuffix(".xcassets") ? folderName : "\(folderName).xcassets"
    let nodes = try parseNodes(in: catalogURL, catalogURL: catalogURL)
    return AssetCatalog(catalogName) { nodes }
  }

  /// Recursively parses child directories into strongly typed asset nodes.
  private static func parseNodes(
    in directory: URL, catalogURL: URL
  ) throws(ResourceGeneratorError)
    -> [any AssetNode]
  {
    let directories = try AssetDirectoryScanner.childDirectories(
      in: directory, catalogURL: catalogURL)
    var nodes: [any AssetNode] = []

    for item in directories {
      switch item.pathExtension {
        case "imageset":
          nodes.append(try ImageSetParser.parse(at: item, catalogURL: catalogURL))
        case "colorset":
          nodes.append(try ColorSetParser.parse(at: item, catalogURL: catalogURL))
        case "dataset":
          nodes.append(try DataSetParser.parse(at: item, catalogURL: catalogURL))
        case "symbolset":
          nodes.append(try SymbolSetParser.parse(at: item, catalogURL: catalogURL))
        case "appiconset":
          nodes.append(try AppIconSetParser.parse(at: item, catalogURL: catalogURL))
        default:
          let children = try parseNodes(in: item, catalogURL: catalogURL)
          nodes.append(AssetGroup(item.lastPathComponent) { children })
      }
    }

    return nodes
  }
}
