import Foundation

/// Opt-in protocol for resources with custom validation logic.
protocol ResourceValidating {
  /// Validates resource configuration.
  func validate() throws(ResourceGeneratorError)
}

/// Internal validation pipeline for resources and generated entries.
enum ResourceValidator {
  /// Runs resource-level and entry-level validation.
  static func validate(
    resources: [any Resource], entries: [GeneratedEntry]
  ) throws(ResourceGeneratorError) {
    for resource in resources {
      if let validating = resource as? any ResourceValidating {
        try validating.validate()
      }
    }

    var seen: [String: GeneratedEntry.Kind] = [:]

    for entry in entries {
      let path = entry.normalizedPath
      try validateRelativePath(path)

      if let existing = seen[path] {
        if !kind(existing, matches: entry.kind) {
          throw ResourceGeneratorError.validation(
            .init(path: path, reason: .conflictingEntryKinds)
          )
        }

        throw ResourceGeneratorError.validation(
          .init(path: path, reason: .duplicatePath)
        )
      }

      seen[path] = entry.kind
    }
  }

  /// Validates a logical name used in paths.
  static func validateName(_ name: String, at path: String? = nil) throws(ResourceGeneratorError) {
    let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty, !trimmed.contains("/"), !trimmed.contains("\\") else {
      throw ResourceGeneratorError.validation(
        .init(path: path ?? name, reason: .invalidName, details: "name contains invalid characters")
      )
    }
  }

  /// Creates a typed invalid-configuration error.
  static func invalidAssetConfiguration(path: String, details: String) -> ResourceGeneratorError {
    .validation(
      .init(path: path, reason: .invalidAssetConfiguration, details: details)
    )
  }

  /// Enforces safe relative output paths.
  private static func validateRelativePath(_ path: String) throws(ResourceGeneratorError) {
    if path.hasPrefix("/") || path.contains("../") || path == ".." {
      throw ResourceGeneratorError.validation(
        .init(path: path, reason: .invalidRelativePath)
      )
    }
  }

  /// Compares entry kinds while ignoring file payload bytes.
  private static func kind(_ lhs: GeneratedEntry.Kind, matches rhs: GeneratedEntry.Kind) -> Bool {
    switch (lhs, rhs) {
      case (.directory, .directory), (.file, .file):
        return true
      default:
        return false
    }
  }
}
