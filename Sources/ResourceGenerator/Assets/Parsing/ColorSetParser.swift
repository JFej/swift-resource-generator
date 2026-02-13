import Foundation

/// Parser for `.colorset` nodes.
enum ColorSetParser {
  /// Parses one `.colorset` directory.
  static func parse(at url: URL, catalogURL: URL) throws(ResourceGeneratorError) -> AssetColorSet {
    let name = url.deletingPathExtension().lastPathComponent
    let contents = try ParserModelLoader.decode(
      ColorSetContents.self,
      from: url,
      catalogURL: catalogURL,
      assetKind: .colorSet
    )

    do {
      let entries = try contents.colors.map { color in
        AssetColorSet.Entry(
          idiom: try ParserModelLoader.requiredEnum(
            AssetIdiom.self, field: "idiom", value: color.idiom),
          color: .init(
            colorSpace: color.color.colorSpace,
            components: .init(
              red: color.color.components.red,
              green: color.color.components.green,
              blue: color.color.components.blue,
              alpha: color.color.components.alpha
            )
          ),
          appearances: color.appearances
        )
      }

      return AssetColorSet(name, entries: entries)
    } catch {
      throw ResourceGeneratorError.parse(
        .init(
          catalogPath: catalogURL.path,
          nodePath: url.path,
          assetKind: .colorSet,
          underlyingErrorDescription: String(describing: error)
        )
      )
    }
  }
}
