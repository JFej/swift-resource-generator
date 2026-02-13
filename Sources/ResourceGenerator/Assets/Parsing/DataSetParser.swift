import Foundation

/// Parser for `.dataset` nodes.
enum DataSetParser {
  /// Parses one `.dataset` directory.
  static func parse(at url: URL, catalogURL: URL) throws(ResourceGeneratorError) -> AssetDataSet {
    let name = url.deletingPathExtension().lastPathComponent
    let contents = try ParserModelLoader.decode(
      DataSetContents.self,
      from: url,
      catalogURL: catalogURL,
      assetKind: .dataSet
    )

    do {
      let files = try contents.data.map { item in
        let filename = try ParserModelLoader.requiredString(field: "filename", value: item.filename)
        let idiom = try ParserModelLoader.requiredEnum(
          AssetIdiom.self, field: "idiom", value: item.idiom)

        return AssetDataSet.File(
          metadata: .init(
            filename: filename,
            idiom: idiom,
            universalTypeIdentifier: item.universalTypeIdentifier
          ),
          source: .file(url.appendingPathComponent(filename))
        )
      }

      return AssetDataSet(name, files: files)
    } catch {
      throw ResourceGeneratorError.parse(
        .init(
          catalogPath: catalogURL.path,
          nodePath: url.path,
          assetKind: .dataSet,
          underlyingErrorDescription: String(describing: error)
        )
      )
    }
  }
}
