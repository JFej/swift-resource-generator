import Foundation
import Testing

@testable import ResourceGenerator

@Test func appIconMarketingEntryMatchesXcodeShape() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      AppIconSet(
        "AppIcon",
        icons: [
          AppIcon(
            filename: "app_icon.png", source: .data(Data([0x12, 0x34, 0x56, 0x78])),
            idiom: .universal, size: "1024x1024", scale: .x1)
        ]
      )
    }
  }

  try package.write(to: output)

  let contents = try json(
    from: output.appendingPathComponent("Assets.xcassets/AppIcon.appiconset/Contents.json"))
  let images = try #require(contents["images"] as? [[String: Any]])
  let icon = try #require(images.first)

  #expect(icon["idiom"] as? String == "universal")
  #expect(icon["platform"] as? String == "ios")
  #expect(icon["size"] as? String == "1024x1024")
  #expect(icon["scale"] == nil)
}

@Test func appIconValidationRejectsInconsistentFilenameSource() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let missingSource = ResourcePackage {
    AssetCatalog("Assets") {
      AppIconSet(
        "AppIcon",
        icons: [AppIcon(filename: "icon.png", source: nil, idiom: .iphone, size: "20x20")])
    }
  }

  expectValidationError({ try missingSource.write(to: output) }) { context in
    #expect(context.reason == .invalidAssetConfiguration)
    #expect(context.path.contains("Assets.xcassets/AppIcon"))
  }

  let sourceWithoutFilename = ResourcePackage {
    AssetCatalog("Assets") {
      AppIconSet(
        "AppIcon",
        icons: [AppIcon(filename: nil, source: .data(Data([0x01])), idiom: .iphone, size: "20x20")])
    }
  }

  expectValidationError({ try sourceWithoutFilename.write(to: output) }) { context in
    #expect(context.reason == .invalidAssetConfiguration)
    #expect(context.path.contains("Assets.xcassets/AppIcon"))
  }
}
