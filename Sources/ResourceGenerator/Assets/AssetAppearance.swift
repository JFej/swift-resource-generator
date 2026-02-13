import Foundation

/// Appearance trait used by xcassets image/color entries.
public struct AssetAppearance: Codable, Sendable, Equatable {
  /// Trait domain key (`luminosity`, `contrast`, ...).
  public let appearance: String
  /// Trait value for the domain key.
  public let value: String

  /// Creates an arbitrary appearance entry.
  public init(appearance: String, value: String) {
    self.appearance = appearance
    self.value = value
  }

  /// Convenience constructor for luminosity traits.
  public static func luminosity(_ value: Luminosity) -> AssetAppearance {
    .init(appearance: "luminosity", value: value.rawValue)
  }

  /// Convenience constructor for contrast traits.
  public static func contrast(_ value: Contrast) -> AssetAppearance {
    .init(appearance: "contrast", value: value.rawValue)
  }

  /// Known luminosity values.
  public enum Luminosity: String, Sendable {
    case light
    case dark
  }

  /// Known contrast values.
  public enum Contrast: String, Sendable {
    case normal
    case high
  }
}
