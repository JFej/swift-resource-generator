import Foundation
import Testing

@testable import ResourceGenerator

@Test func supportsPlanDiffAndDryRun() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      ColorSet("Primary", red: 1, green: 0, blue: 0)
    }
  }

  let dryRunBefore = try package.write(
    to: output, options: .init(mode: .overwrite, dryRun: true, validateBeforeWrite: true))
  #expect(dryRunBefore.dryRun)
  #expect(dryRunBefore.writtenFilesCount == 0)
  #expect(dryRunBefore.diff.createdFiles.isEmpty == false)

  _ = try package.write(to: output)

  let dryRunAfter = try package.write(
    to: output, options: .init(mode: .overwrite, dryRun: true, validateBeforeWrite: true))
  #expect(dryRunAfter.diff.unchangedFiles.isEmpty == false)
}

@Test func mergeModesBehaveAsExpected() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let first = ResourcePackage {
    AssetCatalog("Assets") {
      ColorSet("Primary", red: 1, green: 0, blue: 0)
    }
  }

  let second = ResourcePackage {
    AssetCatalog("Assets") {
      ColorSet("Primary", red: 0, green: 0, blue: 1)
    }
  }

  _ = try first.write(to: output)
  _ = try second.write(to: output, options: .init(mode: .mergePreferExisting))

  var metadata = try json(
    from: output.appendingPathComponent("Assets.xcassets/Primary.colorset/Contents.json"))
  var colors = try #require(metadata["colors"] as? [[String: Any]])
  let firstColor = try #require(colors.first)
  var components = try #require(firstColor["color"] as? [String: Any])
  components = try #require(components["components"] as? [String: Any])
  #expect(components["red"] as? String == "0xFF")

  _ = try second.write(to: output, options: .init(mode: .mergePreferGenerated))
  metadata = try json(
    from: output.appendingPathComponent("Assets.xcassets/Primary.colorset/Contents.json"))
  colors = try #require(metadata["colors"] as? [[String: Any]])
  let firstColorAfter = try #require(colors.first)
  components = try #require(firstColorAfter["color"] as? [String: Any])
  components = try #require(components["components"] as? [String: Any])
  #expect(components["blue"] as? String == "0xFF")
}
