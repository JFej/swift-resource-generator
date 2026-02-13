import Foundation
import Testing

@testable import ResourceGenerator

func temporaryDirectory() -> URL {
  let directory = FileManager.default.temporaryDirectory
    .appendingPathComponent("resource-generator-tests")
    .appendingPathComponent(UUID().uuidString)
  try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
  return directory
}

func json(from url: URL) throws -> [String: Any] {
  let data = try Data(contentsOf: url)
  let object = try JSONSerialization.jsonObject(with: data)
  guard let dictionary = object as? [String: Any] else {
    throw NSError(domain: "TestError", code: 1)
  }
  return dictionary
}

func expectValidationError(
  _ body: () throws -> Void,
  _ validate: (ValidationErrorContext) -> Void
) {
  do {
    try body()
    Issue.record("Expected validation error")
  } catch let ResourceGeneratorError.validation(context) {
    validate(context)
  } catch {
    Issue.record("Expected validation error, got \(error)")
  }
}

func expectParseError(
  _ body: () throws -> Void,
  _ validate: (ParseErrorContext) -> Void
) {
  do {
    try body()
    Issue.record("Expected parse error")
  } catch let ResourceGeneratorError.parse(context) {
    validate(context)
  } catch {
    Issue.record("Expected parse error, got \(error)")
  }
}
