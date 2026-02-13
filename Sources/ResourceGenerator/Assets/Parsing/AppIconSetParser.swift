import Foundation

/// Parser for `.appiconset` nodes.
enum AppIconSetParser {
  /// Parses one `.appiconset` directory.
  static func parse(
    at url: URL, catalogURL: URL
  ) throws(ResourceGeneratorError)
    -> AssetAppIconSet
  {
    let name = url.deletingPathExtension().lastPathComponent
    let contents = try ParserModelLoader.decode(
      AppIconSetContents.self,
      from: url,
      catalogURL: catalogURL,
      assetKind: .appIconSet
    )

    do {
      let icons = try contents.images.map { image in
        let idiom = try ParserModelLoader.requiredEnum(
          AssetIdiom.self, field: "idiom", value: image.idiom)
        let scale = try image.scale.map { value in
          try ParserModelLoader.requiredEnum(AssetScale.self, field: "scale", value: value)
        }
        let platform = try image.platform.map { value in
          try ParserModelLoader.requiredEnum(AssetPlatform.self, field: "platform", value: value)
        }

        return AssetAppIconSet.Icon(
          metadata: .init(
            filename: image.filename,
            idiom: idiom,
            size: image.size,
            scale: scale,
            platform: platform
          ),
          source: image.filename.map { .file(url.appendingPathComponent($0)) }
        )
      }

      return AssetAppIconSet(name, icons: icons)
    } catch {
      throw ResourceGeneratorError.parse(
        .init(
          catalogPath: catalogURL.path,
          nodePath: url.path,
          assetKind: .appIconSet,
          underlyingErrorDescription: String(describing: error)
        )
      )
    }
  }
}
