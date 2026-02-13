import Foundation

/// Shared JSON encoding helpers for xcassets payloads.
enum AssetCatalogJSON {
  /// Encodes payload using pretty-printed, sorted-key JSON.
  static func encode(
    _ value: some Encodable, for path: String
  ) throws(ResourceGeneratorError)
    -> Data
  {
    do {
      let encoder = JSONEncoder()
      encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
      return try encoder.encode(value)
    } catch {
      throw ResourceGeneratorError.validation(
        .init(
          path: path,
          reason: .invalidAssetConfiguration,
          details: "failed to encode Contents.json: \(String(describing: error))"
        )
      )
    }
  }

  /// Standard xcassets info block.
  static let info = AssetCatalogInfo(author: "xcode", version: 1)
}

/// Minimal `info` structure used by asset contents files.
struct AssetCatalogInfo: Encodable, Sendable {
  let author: String
  let version: Int
}

/// Root catalog `Contents.json` structure.
struct AssetCatalogRootContents: Encodable, Sendable {
  let info: AssetCatalogInfo
}
