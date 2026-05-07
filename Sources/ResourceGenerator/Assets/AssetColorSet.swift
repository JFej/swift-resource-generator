import Foundation

/// `.colorset` node model.
public struct AssetColorSet: AssetNode, Sendable {
  /// Metadata entry written into `Contents.json`.
  public struct Entry: Encodable, Sendable {
    /// Device idiom this color applies to.
    public let idiom: AssetIdiom
    /// Color value definition.
    public let color: ColorDefinition
    /// Optional appearance filters.
    public let appearances: [AssetAppearance]?

    /// Creates a color entry.
    public init(
      idiom: AssetIdiom = .universal,
      color: ColorDefinition,
      appearances: [AssetAppearance]? = nil
    ) {
      self.idiom = idiom
      self.color = color
      self.appearances = appearances
    }
  }

  /// Encodable color payload for xcassets.
  public struct ColorDefinition: Encodable, Sendable {
    /// Color space identifier (`srgb`, ...).
    public let colorSpace: String
    /// RGBA components.
    public let components: Components

    enum CodingKeys: String, CodingKey {
      case colorSpace = "color-space"
      case components
    }

    /// Creates a color definition from explicit components.
    public init(colorSpace: String = "srgb", components: Components) {
      self.colorSpace = colorSpace
      self.components = components
    }
  }

  /// RGBA components for xcassets color definitions.
  public struct Components: Encodable, Sendable {
    /// Red component string (usually hex).
    public let red: String
    /// Green component string (usually hex).
    public let green: String
    /// Blue component string (usually hex).
    public let blue: String
    /// Alpha component string (usually hex).
    public let alpha: String

    /// Creates components from preformatted strings.
    public init(red: String, green: String, blue: String, alpha: String) {
      self.red = red
      self.green = green
      self.blue = blue
      self.alpha = alpha
    }

    /// Creates components from normalized 0...1 doubles.
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
      self.red = Components.hexString(red)
      self.green = Components.hexString(green)
      self.blue = Components.hexString(blue)
      self.alpha = Components.hexString(alpha)
    }

    private static func hexString(_ value: Double) -> String {
      let clamped = min(1, max(0, value))
      return String(format: "0x%02X", Int((clamped * 255).rounded()))
    }
  }

  private struct ContentsFile: Encodable, Sendable {
    let colors: [Entry]
    let info: AssetCatalogInfo
  }

  /// Logical asset name without `.colorset`.
  public let name: String
  private let entries: [Entry]

  /// Creates a color set.
  public init(_ name: String, entries: [Entry]) {
    self.name = name
    self.entries = entries
  }

  /// Convenience constructor for a single color entry.
  public static func single(
    _ name: String,
    red: Double,
    green: Double,
    blue: Double,
    alpha: Double = 1.0,
    appearances: [AssetAppearance]? = nil
  ) -> AssetColorSet {
    AssetColorSet(
      name,
      entries: [
        .init(
          color: .init(components: .init(red: red, green: green, blue: blue, alpha: alpha)),
          appearances: appearances
        )
      ]
    )
  }

  /// Validates set name and non-empty entries.
  public func validate(in parentPath: String) throws(ResourceGeneratorError) {
    let path = "\(parentPath)/\(name)"
    try ResourceValidator.validateName(name, at: path)
    guard !entries.isEmpty else {
      throw ResourceValidator.invalidAssetConfiguration(
        path: path,
        details: "expects at least one color entry"
      )
    }

    _ = try normalizedEntriesForGeneration()
  }

  /// Generates the `.colorset` directory and `Contents.json`.
  public func generateEntries(
    in parentPath: String
  ) throws(ResourceGeneratorError)
    -> [GeneratedEntry]
  {
    let setPath = "\(parentPath)/\(name).colorset"
    let normalizedEntries = try normalizedEntriesForGeneration()
    return [
      .directory(setPath),
      .file(
        "\(setPath)/Contents.json",
        try AssetCatalogJSON.encode(
          ContentsFile(colors: normalizedEntries, info: AssetCatalogJSON.info),
          for: "\(setPath)/Contents.json"
        )
      ),
    ]
  }

  /// Ensures dynamic color fallbacks are encoded in Xcode-compatible form.
  private func normalizedEntriesForGeneration() throws(ResourceGeneratorError) -> [Entry] {
    var normalized = entries
    let hasUnscopedAny = normalized.contains { luminosity(in: $0.appearances) == nil }
    guard !hasUnscopedAny else { return normalized }

    let lightIndex = normalized.firstIndex { luminosity(in: $0.appearances) == .light }
    let hasDark = normalized.contains { luminosity(in: $0.appearances) == .dark }

    guard let lightIndex, hasDark else { return normalized }

    let original = normalized[lightIndex]
    normalized[lightIndex] = Entry(
      idiom: original.idiom,
      color: original.color,
      appearances: removingLuminosity(from: original.appearances)
    )
    return normalized
  }

  private func luminosity(in appearances: [AssetAppearance]?) -> AssetAppearance.Luminosity? {
    guard let appearances else { return nil }
    for appearance in appearances where appearance.appearance == "luminosity" {
      return AssetAppearance.Luminosity(rawValue: appearance.value)
    }
    return nil
  }

  private func removingLuminosity(from appearances: [AssetAppearance]?) -> [AssetAppearance]? {
    guard let appearances else { return nil }
    let filtered = appearances.filter { $0.appearance != "luminosity" }
    return filtered.isEmpty ? nil : filtered
  }
}
