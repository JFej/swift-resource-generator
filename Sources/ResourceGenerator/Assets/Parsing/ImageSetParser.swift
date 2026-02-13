import Foundation

/// Parser for `.imageset` nodes.
enum ImageSetParser {
  /// Parses one `.imageset` directory.
  static func parse(at url: URL, catalogURL: URL) throws(ResourceGeneratorError) -> AssetImageSet {
    let name = url.deletingPathExtension().lastPathComponent
    let contents = try ParserModelLoader.decode(
      ImageSetContents.self,
      from: url,
      catalogURL: catalogURL,
      assetKind: .imageSet
    )

    do {
      let variants: [AssetImageSet.VariantSource] = try contents.images.compactMap { image in
        guard let filename = image.filename else { return nil }

        let idiom = try ParserModelLoader.requiredEnum(
          AssetIdiom.self, field: "idiom", value: image.idiom)
        let scale = try ParserModelLoader.requiredEnum(
          AssetScale.self,
          field: "scale",
          value: image.scale ?? "1x"
        )

        return .init(
          variant: .init(
            filename: filename,
            idiom: idiom,
            scale: scale,
            appearances: image.appearances
          ),
          source: .file(url.appendingPathComponent(filename))
        )
      }

      return AssetImageSet(name) { variants }
    } catch {
      throw ResourceGeneratorError.parse(
        .init(
          catalogPath: catalogURL.path,
          nodePath: url.path,
          assetKind: .imageSet,
          underlyingErrorDescription: String(describing: error)
        )
      )
    }
  }
}
