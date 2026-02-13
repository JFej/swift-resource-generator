import Foundation

/// Parser for `.symbolset` nodes.
enum SymbolSetParser {
  /// Parses one `.symbolset` directory.
  static func parse(at url: URL, catalogURL: URL) throws(ResourceGeneratorError) -> AssetSymbolSet {
    let name = url.deletingPathExtension().lastPathComponent
    let contents = try ParserModelLoader.decode(
      SymbolSetContents.self,
      from: url,
      catalogURL: catalogURL,
      assetKind: .symbolSet
    )

    do {
      let files = try contents.symbols.map { symbol in
        let filename = try ParserModelLoader.requiredString(
          field: "filename", value: symbol.filename)

        return AssetSymbolSet.File(
          metadata: .init(filename: filename),
          source: .file(url.appendingPathComponent(filename))
        )
      }

      return AssetSymbolSet(name, files: files)
    } catch {
      throw ResourceGeneratorError.parse(
        .init(
          catalogPath: catalogURL.path,
          nodePath: url.path,
          assetKind: .symbolSet,
          underlyingErrorDescription: String(describing: error)
        )
      )
    }
  }
}
