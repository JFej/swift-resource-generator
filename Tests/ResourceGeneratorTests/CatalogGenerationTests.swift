import Foundation
import Testing

@testable import ResourceGenerator

@Test func writesCatalogWithNestedNodes() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let imageBytes = Data([0x89, 0x50, 0x4E, 0x47])

  let package = ResourcePackage {
    AssetCatalog("AppAssets") {
      ImageSet("Logo", filename: "logo.png", source: .data(imageBytes), scale: .x2)
      ColorSet("Primary", red: 0.2, green: 0.4, blue: 0.6)
      Group("Nested") {
        ColorSet("Accent", red: 1, green: 0, blue: 0)
      }
    }
  }

  try package.write(to: output)

  let root = output.appendingPathComponent("AppAssets.xcassets")
  #expect(FileManager.default.fileExists(atPath: root.path))
  #expect(FileManager.default.fileExists(atPath: root.appendingPathComponent("Contents.json").path))
  #expect(
    FileManager.default.fileExists(
      atPath: root.appendingPathComponent("Logo.imageset/logo.png").path))
  #expect(
    FileManager.default.fileExists(
      atPath: root.appendingPathComponent("Primary.colorset/Contents.json").path))
  #expect(
    FileManager.default.fileExists(
      atPath: root.appendingPathComponent("Nested/Accent.colorset/Contents.json").path))

  let logoData = try Data(contentsOf: root.appendingPathComponent("Logo.imageset/logo.png"))
  #expect(logoData == imageBytes)
}

@Test func supportsBuilderControlFlow() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let includeNested = true
  let dynamicColors = ["One", "Two", "Three"]

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      if includeNested {
        Group("Nested") {
          for name in dynamicColors {
            ColorSet(name, red: 1, green: 0, blue: 0)
          }
        }
      } else {
        ColorSet("Fallback", red: 0, green: 0, blue: 0)
      }
    }
  }

  try package.write(to: output)

  let root = output.appendingPathComponent("Assets.xcassets/Nested")
  for name in dynamicColors {
    #expect(
      FileManager.default.fileExists(
        atPath: root.appendingPathComponent("\(name).colorset/Contents.json").path))
  }
}

@Test func encodesImageAppearances() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      ImageSet("Hero") {
        ImageVariant(
          filename: "hero-light.png",
          source: .data(Data([0x01])),
          scale: .x2,
          appearances: [.luminosity(.light)])
        ImageVariant(
          filename: "hero-dark.png",
          source: .data(Data([0x02])),
          scale: .x2,
          appearances: [.luminosity(.dark), .contrast(.high)])
      }
    }
  }

  try package.write(to: output)

  let metadata = try json(
    from: output.appendingPathComponent("Assets.xcassets/Hero.imageset/Contents.json"))
  let images = try #require(metadata["images"] as? [[String: Any]])
  #expect(images.count == 2)

  let dark = try #require(images.first { ($0["filename"] as? String) == "hero-dark.png" })
  let appearances = try #require(dark["appearances"] as? [[String: Any]])
  #expect(appearances.count == 2)
}

@Test func clampsColorComponentsIntoHexRange() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      ColorSet(
        "Clamped", red: -0.5, green: 0.5, blue: 1.4, alpha: 2.0, appearances: [.luminosity(.dark)])
    }
  }

  try package.write(to: output)

  let metadata = try json(
    from: output.appendingPathComponent("Assets.xcassets/Clamped.colorset/Contents.json"))
  let colors = try #require(metadata["colors"] as? [[String: Any]])
  let color = try #require(colors.first)
  let definition = try #require(color["color"] as? [String: Any])
  let components = try #require(definition["components"] as? [String: Any])

  #expect(components["red"] as? String == "0x00")
  #expect(components["green"] as? String == "0x80")
  #expect(components["blue"] as? String == "0xFF")
  #expect(components["alpha"] as? String == "0xFF")
}

@Test func encodesColorSetWithMultipleAppearanceVariants() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      AssetColorSet(
        "Theme",
        entries: [
          .init(
            color: .init(components: .init(red: 1, green: 1, blue: 1, alpha: 1)),
            appearances: [.luminosity(.light)]
          ),
          .init(
            color: .init(components: .init(red: 0, green: 0, blue: 0, alpha: 1)),
            appearances: [.luminosity(.dark)]
          ),
          .init(
            color: .init(components: .init(red: 0, green: 0.5, blue: 1, alpha: 1)),
            appearances: [.luminosity(.dark), .contrast(.high)]
          ),
        ]
      )
    }
  }

  try package.write(to: output)

  let metadata = try json(
    from: output.appendingPathComponent("Assets.xcassets/Theme.colorset/Contents.json"))
  let colors = try #require(metadata["colors"] as? [[String: Any]])
  #expect(colors.count == 3)

  let any = try #require(
    colors.first { entry in
      let appearances = entry["appearances"] as? [[String: Any]]
      return appearances == nil
    })
  var definition = try #require(any["color"] as? [String: Any])
  var components = try #require(definition["components"] as? [String: Any])
  #expect(components["red"] as? String == "0xFF")

  #expect(
    colors.contains { entry in
      guard let appearances = entry["appearances"] as? [[String: Any]] else { return false }
      return appearances.contains {
        ($0["appearance"] as? String) == "luminosity" && ($0["value"] as? String) == "light"
      }
    } == false)

  let dark = try #require(
    colors.first { entry in
      guard let appearances = entry["appearances"] as? [[String: Any]] else { return false }
      return appearances.count == 1
        && appearances.contains {
          ($0["appearance"] as? String) == "luminosity" && ($0["value"] as? String) == "dark"
        }
    })
  definition = try #require(dark["color"] as? [String: Any])
  components = try #require(definition["components"] as? [String: Any])
  #expect(components["red"] as? String == "0x00")

  let darkHighContrast = try #require(
    colors.first { entry in
      guard let appearances = entry["appearances"] as? [[String: Any]] else { return false }
      return appearances.count == 2
        && appearances.contains {
          ($0["appearance"] as? String) == "luminosity" && ($0["value"] as? String) == "dark"
        }
        && appearances.contains {
          ($0["appearance"] as? String) == "contrast" && ($0["value"] as? String) == "high"
        }
    })
  definition = try #require(darkHighContrast["color"] as? [String: Any])
  components = try #require(definition["components"] as? [String: Any])
  #expect(components["green"] as? String == "0x80")
  #expect(components["blue"] as? String == "0xFF")
}

@Test func rewritesLightDarkColorSetIntoAnyDarkFallbackShape() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      AssetColorSet(
        "LaunchScreenBackgroundColor",
        entries: [
          .init(
            color: .init(components: .init(red: 0, green: 0.3686, blue: 0.7255, alpha: 1)),
            appearances: [.luminosity(.light)]
          ),
          .init(
            color: .init(components: .init(red: 0.0706, green: 0.2549, blue: 0.4314, alpha: 1)),
            appearances: [.luminosity(.dark)]
          ),
        ]
      )
    }
  }

  try package.write(to: output)

  let metadata = try json(
    from: output.appendingPathComponent(
      "Assets.xcassets/LaunchScreenBackgroundColor.colorset/Contents.json"))
  let colors = try #require(metadata["colors"] as? [[String: Any]])
  #expect(colors.count == 2)

  let any = try #require(
    colors.first { entry in
      let appearances = entry["appearances"] as? [[String: Any]]
      return appearances == nil
    })
  let dark = try #require(
    colors.first { entry in
      guard let appearances = entry["appearances"] as? [[String: Any]] else { return false }
      return appearances.count == 1
        && appearances.contains {
          ($0["appearance"] as? String) == "luminosity" && ($0["value"] as? String) == "dark"
        }
    })

  var definition = try #require(any["color"] as? [String: Any])
  var components = try #require(definition["components"] as? [String: Any])
  #expect(components["green"] as? String == "0x5E")

  definition = try #require(dark["color"] as? [String: Any])
  components = try #require(definition["components"] as? [String: Any])
  #expect(components["red"] as? String == "0x12")
}

@Test func supportsDataSymbolAndAppIconSets() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      DataSet(
        "Payload",
        files: [
          DataFile(
            filename: "blob.json", source: .data(Data("{}".utf8)),
            universalTypeIdentifier: "public.json")
        ]
      )
      SymbolSet(
        "Plus",
        files: [
          SymbolFile(filename: "plus.svg", source: .data(Data("<svg/>".utf8)))
        ]
      )
      AppIconSet(
        "AppIcon",
        icons: [
          AppIcon(
            filename: "icon-20.png", source: .data(Data([0xAB, 0xCD])), idiom: .iphone,
            size: "20x20", scale: .x2)
        ]
      )
    }
  }

  try package.write(to: output)

  #expect(
    FileManager.default.fileExists(
      atPath: output.appendingPathComponent("Assets.xcassets/Payload.dataset/blob.json").path))
  #expect(
    FileManager.default.fileExists(
      atPath: output.appendingPathComponent("Assets.xcassets/Plus.symbolset/plus.svg").path))
  #expect(
    FileManager.default.fileExists(
      atPath: output.appendingPathComponent("Assets.xcassets/AppIcon.appiconset/icon-20.png").path))
}

@Test func deterministicPlanOrder() throws {
  let package = ResourcePackage {
    AssetCatalog("Assets") {
      Group("B") {
        ColorSet("Z", red: 1, green: 1, blue: 1)
      }
      Group("A") {
        ColorSet("Y", red: 0, green: 0, blue: 0)
      }
    }
  }

  let plan = try package.plan()
  let paths = plan.entries.map(\.relativePath)
  let sorted = paths.sorted()
  #expect(paths == sorted)
}

@Test func snapshotLikeColorSetJSONStaysStable() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      ColorSet("Primary", red: 0, green: 0.5, blue: 1)
    }
  }

  try package.write(to: output)

  let file = output.appendingPathComponent("Assets.xcassets/Primary.colorset/Contents.json")
  let raw = try String(contentsOf: file, encoding: .utf8)

  #expect(raw.contains("\"color-space\" : \"srgb\""))
  #expect(raw.contains("\"green\" : \"0x80\""))
  #expect(raw.contains("\"version\" : 1"))
}
