import Foundation

/// Semantic value errors produced while converting raw parser models.
enum ParserValueError: Error {
  case missingRequiredField(String)
  case invalidValue(field: String, value: String)
}

extension ParserValueError: LocalizedError {
  var errorDescription: String? {
    switch self {
      case .missingRequiredField(let field):
        return "missing required field '\(field)'"
      case .invalidValue(let field, let value):
        return "invalid value '\(value)' for field '\(field)'"
    }
  }
}

/// Shared helpers for decoding `Contents.json` parser models.
enum ParserModelLoader {
  /// Loads and decodes `Contents.json` at `baseURL`.
  static func decode<T: Decodable>(
    _ type: T.Type,
    from baseURL: URL,
    catalogURL: URL,
    assetKind: ParseAssetKind
  ) throws(ResourceGeneratorError) -> T {
    do {
      let data = try Data(contentsOf: baseURL.appendingPathComponent("Contents.json"))
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw ResourceGeneratorError.parse(
        .init(
          catalogPath: catalogURL.path,
          nodePath: baseURL.path,
          assetKind: assetKind,
          underlyingErrorDescription: String(describing: error)
        )
      )
    }
  }

  /// Parses required string-backed enums and reports invalid values.
  static func requiredEnum<T: RawRepresentable>(
    _ type: T.Type,
    field: String,
    value: String
  ) throws -> T where T.RawValue == String {
    guard let parsed = T(rawValue: value) else {
      throw ParserValueError.invalidValue(field: field, value: value)
    }

    return parsed
  }

  /// Parses required strings and reports missing values.
  static func requiredString(field: String, value: String?) throws -> String {
    guard let value, !value.isEmpty else {
      throw ParserValueError.missingRequiredField(field)
    }

    return value
  }
}

/// Decodable representation of `.imageset/Contents.json`.
struct ImageSetContents: Decodable {
  let images: [Image]

  /// Decodable image metadata entry.
  struct Image: Decodable {
    let filename: String?
    let idiom: String
    let scale: String?
    let appearances: [AssetAppearance]?
  }
}

/// Decodable representation of `.colorset/Contents.json`.
struct ColorSetContents: Decodable {
  let colors: [Color]

  /// Decodable color metadata entry.
  struct Color: Decodable {
    let idiom: String
    let color: Definition
    let appearances: [AssetAppearance]?

    /// Decodable color payload.
    struct Definition: Decodable {
      let colorSpace: String
      let components: Components

      enum CodingKeys: String, CodingKey {
        case colorSpace = "color-space"
        case components
      }

      /// Decodable RGBA components.
      struct Components: Decodable {
        let red: String
        let green: String
        let blue: String
        let alpha: String
      }
    }
  }
}

/// Decodable representation of `.dataset/Contents.json`.
struct DataSetContents: Decodable {
  let data: [DataEntry]

  /// Decodable dataset metadata entry.
  struct DataEntry: Decodable {
    let filename: String?
    let idiom: String
    let universalTypeIdentifier: String?

    enum CodingKeys: String, CodingKey {
      case filename
      case idiom
      case universalTypeIdentifier = "universal-type-identifier"
    }
  }
}

/// Decodable representation of `.symbolset/Contents.json`.
struct SymbolSetContents: Decodable {
  let symbols: [Symbol]

  /// Decodable symbol metadata entry.
  struct Symbol: Decodable {
    let filename: String
  }
}

/// Decodable representation of `.appiconset/Contents.json`.
struct AppIconSetContents: Decodable {
  let images: [Image]

  /// Decodable app icon metadata entry.
  struct Image: Decodable {
    let filename: String?
    let idiom: String
    let size: String
    let scale: String?
    let platform: String?
  }
}
