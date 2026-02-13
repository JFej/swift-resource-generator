import Foundation
import Testing

@testable import ResourceGenerator

@Test func validatesDuplicateNodeNames() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      ColorSet("Primary", red: 1, green: 0, blue: 0)
      ColorSet("Primary", red: 0, green: 1, blue: 0)
    }
  }

  expectValidationError({ try package.write(to: output) }) { context in
    #expect(context.reason == .duplicatePath)
    #expect(context.path == "Assets.xcassets/Primary")
  }
}

@Test func validatesDuplicateDataSetFilenames() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      DataSet(
        "Payload",
        files: [
          DataFile(filename: "duplicate.json", source: .data(Data([0x01]))),
          DataFile(filename: "duplicate.json", source: .data(Data([0x02]))),
        ]
      )
    }
  }

  expectValidationError({ try package.write(to: output) }) { context in
    #expect(context.reason == .invalidAssetConfiguration)
    #expect(context.path.contains("Assets.xcassets/Payload"))
  }
}

@Test func validatesDuplicateSymbolSetFilenames() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      SymbolSet(
        "Symbols",
        files: [
          SymbolFile(filename: "dup.svg", source: .data(Data([0x01]))),
          SymbolFile(filename: "dup.svg", source: .data(Data([0x02]))),
        ]
      )
    }
  }

  expectValidationError({ try package.write(to: output) }) { context in
    #expect(context.reason == .invalidAssetConfiguration)
    #expect(context.path.contains("Assets.xcassets/Symbols"))
  }
}

@Test func rejectsNonFileURLForAssetFileSourceFileCase() throws {
  let output = temporaryDirectory()
  defer { try? FileManager.default.removeItem(at: output) }

  let package = ResourcePackage {
    AssetCatalog("Assets") {
      ImageSet(
        "Logo",
        filename: "logo.png",
        source: .file(URL(string: "https://example.com/logo.png")!)
      )
    }
  }

  expectValidationError({ try package.write(to: output) }) { context in
    #expect(context.reason == .invalidAssetConfiguration)
    #expect(context.path == "https://example.com/logo.png")
    #expect(context.details?.contains("only file URLs are supported") == true)
  }
}
