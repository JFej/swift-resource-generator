import Foundation
import Testing

@testable import ResourceGenerator

@Test func parserRoundtripFromFixtureCatalog() throws {
  let output = temporaryDirectory()
  let fixtureRoot = temporaryDirectory()
  defer {
    try? FileManager.default.removeItem(at: output)
    try? FileManager.default.removeItem(at: fixtureRoot)
  }

  let fixture = try makeFixtureCatalog(named: "Styles", in: fixtureRoot)

  let parsedCatalog = try AssetCatalogParser.parseCatalog(at: fixture)
  let package = ResourcePackage { parsedCatalog }

  try package.write(to: output)

  #expect(
    FileManager.default.fileExists(
      atPath:
        output.appendingPathComponent("Styles.xcassets/24Vision/Primary.colorset/Contents.json")
        .path))
  #expect(
    FileManager.default.fileExists(
      atPath: output.appendingPathComponent("Styles.xcassets/Orange.imageset/Orange.png").path))
}

@Test func pluginRegistryResolvesImportPlugin() throws {
  let fixtureRoot = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: fixtureRoot) }

  let fixture = try makeFixtureCatalog(named: "Styles", in: fixtureRoot)

  var registry = ResourcePluginRegistry()
  registry.register(AssetCatalogImportPlugin(catalogPaths: [fixture]))

  let resources = try registry.resources(for: "assetCatalog.import")
  #expect(resources.count == 1)

  #expect(throws: ResourcePluginRegistryError.pluginNotFound("missing")) {
    _ = try registry.resources(for: "missing")
  }
}

private func makeFixtureCatalog(named name: String, in root: URL) throws -> URL {
  let catalog = root.appendingPathComponent("\(name).xcassets")
  let nestedGroup = catalog.appendingPathComponent("24Vision")
  let primaryColor = nestedGroup.appendingPathComponent("Primary.colorset")
  let orangeSet = catalog.appendingPathComponent("Orange.imageset")

  try FileManager.default.createDirectory(at: primaryColor, withIntermediateDirectories: true)
  try FileManager.default.createDirectory(at: orangeSet, withIntermediateDirectories: true)

  let rootContents = """
    {
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
  try rootContents.write(
    to: catalog.appendingPathComponent("Contents.json"),
    atomically: true,
    encoding: .utf8
  )

  try rootContents.write(
    to: nestedGroup.appendingPathComponent("Contents.json"),
    atomically: true,
    encoding: .utf8
  )

  let colorContents = """
    {
      "colors" : [
        {
          "color" : {
            "color-space" : "srgb",
            "components" : {
              "alpha" : "0xFF",
              "blue" : "0x66",
              "green" : "0x80",
              "red" : "0x33"
            }
          },
          "idiom" : "universal"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
  try colorContents.write(
    to: primaryColor.appendingPathComponent("Contents.json"),
    atomically: true,
    encoding: .utf8
  )

  let imageContents = """
    {
      "images" : [
        {
          "filename" : "Orange.png",
          "idiom" : "universal",
          "scale" : "1x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
  try imageContents.write(
    to: orangeSet.appendingPathComponent("Contents.json"),
    atomically: true,
    encoding: .utf8
  )
  try Data([0x89, 0x50, 0x4E, 0x47]).write(to: orangeSet.appendingPathComponent("Orange.png"))

  return catalog
}

@Test func parserFailsForMissingContentsFile() throws {
  let temp = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: temp) }

  let root = temp.appendingPathComponent("Broken.xcassets")
  let imageSet = root.appendingPathComponent("Bad.imageset")

  try FileManager.default.createDirectory(at: imageSet, withIntermediateDirectories: true)

  expectParseError({ _ = try AssetCatalogParser.parseCatalog(at: root) }) { context in
    #expect(context.catalogPath == root.path)
    #expect(context.assetKind == .imageSet)
    #expect(context.nodePath.contains("Bad.imageset"))
  }
}

@Test func parserFailsForInvalidJSON() throws {
  let temp = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: temp) }

  let root = temp.appendingPathComponent("Broken.xcassets")
  let imageSet = root.appendingPathComponent("Bad.imageset")
  try FileManager.default.createDirectory(at: imageSet, withIntermediateDirectories: true)
  try "{ invalid json"
    .write(to: imageSet.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)

  expectParseError({ _ = try AssetCatalogParser.parseCatalog(at: root) }) { context in
    #expect(context.assetKind == .imageSet)
    #expect(context.nodePath.contains("Bad.imageset"))
  }
}

@Test func parserFailsForUnknownImageIdiom() throws {
  let temp = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: temp) }

  let root = temp.appendingPathComponent("Broken.xcassets")
  let imageSet = root.appendingPathComponent("Bad.imageset")
  try FileManager.default.createDirectory(at: imageSet, withIntermediateDirectories: true)

  let json = """
    {
      "images" : [
        { "filename" : "logo.png", "idiom" : "unknown", "scale" : "1x" }
      ],
      "info" : { "author" : "xcode", "version" : 1 }
    }
    """
  try json.write(
    to: imageSet.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)

  expectParseError({ _ = try AssetCatalogParser.parseCatalog(at: root) }) { context in
    #expect(context.assetKind == .imageSet)
    #expect(context.nodePath.contains("Bad.imageset"))
  }
}

@Test func parserFailsForUnknownImageScale() throws {
  let temp = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: temp) }

  let root = temp.appendingPathComponent("Broken.xcassets")
  let imageSet = root.appendingPathComponent("Bad.imageset")
  try FileManager.default.createDirectory(at: imageSet, withIntermediateDirectories: true)

  let json = """
    {
      "images" : [
        { "filename" : "logo.png", "idiom" : "universal", "scale" : "9x" }
      ],
      "info" : { "author" : "xcode", "version" : 1 }
    }
    """
  try json.write(
    to: imageSet.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)

  expectParseError({ _ = try AssetCatalogParser.parseCatalog(at: root) }) { context in
    #expect(context.assetKind == .imageSet)
    #expect(context.nodePath.contains("Bad.imageset"))
  }
}

@Test func parserFailsForUnknownAppIconPlatform() throws {
  let temp = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: temp) }

  let root = temp.appendingPathComponent("Broken.xcassets")
  let appIcon = root.appendingPathComponent("AppIcon.appiconset")
  try FileManager.default.createDirectory(at: appIcon, withIntermediateDirectories: true)

  let json = """
    {
      "images" : [
        { "filename" : "icon.png", "idiom" : "universal", "platform" : "strange", "size" : "1024x1024" }
      ],
      "info" : { "author" : "xcode", "version" : 1 }
    }
    """
  try json.write(
    to: appIcon.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)

  expectParseError({ _ = try AssetCatalogParser.parseCatalog(at: root) }) { context in
    #expect(context.assetKind == .appIconSet)
    #expect(context.nodePath.contains("AppIcon.appiconset"))
  }
}
