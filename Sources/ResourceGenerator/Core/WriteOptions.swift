import Foundation

/// File conflict strategy when writing generated entries.
public enum ResourceWriteMode: String, Sendable, Codable {
  /// Always replace existing files with generated files.
  case overwrite
  /// Stop with an error when a target file already exists.
  case failIfExists
  /// Keep existing files and skip conflicting generated files.
  case mergePreferExisting
  /// Replace conflicting files but leave unrelated existing files untouched.
  case mergePreferGenerated
}

/// Controls validation, planning and write behavior.
public struct ResourceWriteOptions: Sendable {
  /// Conflict strategy applied when a file already exists.
  public var mode: ResourceWriteMode
  /// When enabled, computes the diff and skips all filesystem writes.
  public var dryRun: Bool
  /// Enables pre-write validation for resource configuration and path safety.
  public var validateBeforeWrite: Bool
  /// Sorts entries deterministically for stable output and diffs.
  public var deterministicOrdering: Bool
  /// Skips writes for files where content is unchanged.
  public var skipUnchangedFiles: Bool

  /// Creates write options with safe defaults for CI and local runs.
  public init(
    mode: ResourceWriteMode = .overwrite,
    dryRun: Bool = false,
    validateBeforeWrite: Bool = true,
    deterministicOrdering: Bool = true,
    skipUnchangedFiles: Bool = true
  ) {
    self.mode = mode
    self.dryRun = dryRun
    self.validateBeforeWrite = validateBeforeWrite
    self.deterministicOrdering = deterministicOrdering
    self.skipUnchangedFiles = skipUnchangedFiles
  }

  /// Default options: validate + deterministic ordering + incremental writes.
  public static let `default` = ResourceWriteOptions()
}
