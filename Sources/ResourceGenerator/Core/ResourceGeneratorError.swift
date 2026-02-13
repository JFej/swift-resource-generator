import Foundation

/// Parsed asset node category used in parse error context.
public enum ParseAssetKind: String, Sendable {
  /// The root `.xcassets` catalog.
  case catalog
  /// A folder that is treated as an asset group.
  case group
  /// `.imageset` node.
  case imageSet
  /// `.colorset` node.
  case colorSet
  /// `.dataset` node.
  case dataSet
  /// `.symbolset` node.
  case symbolSet
  /// `.appiconset` node.
  case appIconSet
  /// Unknown or unmapped node kind.
  case unknown
}

/// Validation failure category.
public enum ValidationErrorReason: String, Sendable {
  /// Same normalized path appeared multiple times.
  case duplicatePath
  /// Same path used with incompatible entry kinds.
  case conflictingEntryKinds
  /// Absolute path or traversal was detected.
  case invalidRelativePath
  /// Invalid logical node name.
  case invalidName
  /// Asset-specific semantic mismatch.
  case invalidAssetConfiguration
}

/// Write failure category.
public enum WriteErrorReason: String, Sendable {
  /// Target file exists while mode disallows replacement.
  case fileAlreadyExists
  /// Directory creation failed.
  case createDirectoryFailed
  /// Reading existing file content failed.
  case readExistingFileFailed
  /// Removing a conflicting file failed.
  case removeExistingFileFailed
  /// Writing generated file bytes failed.
  case writeFileFailed
}

/// Structured parse failure payload.
public struct ParseErrorContext: Sendable {
  /// Absolute path of the root catalog being parsed.
  public let catalogPath: String
  /// Absolute path of the node that failed.
  public let nodePath: String
  /// Parsed node category.
  public let assetKind: ParseAssetKind
  /// Description of the original decoding/filesystem error.
  public let underlyingErrorDescription: String

  /// Creates parse error context.
  public init(
    catalogPath: String,
    nodePath: String,
    assetKind: ParseAssetKind,
    underlyingErrorDescription: String
  ) {
    self.catalogPath = catalogPath
    self.nodePath = nodePath
    self.assetKind = assetKind
    self.underlyingErrorDescription = underlyingErrorDescription
  }
}

/// Structured validation failure payload.
public struct ValidationErrorContext: Sendable {
  /// Relative or logical path that failed validation.
  public let path: String
  /// Validation failure category.
  public let reason: ValidationErrorReason
  /// Optional human-readable details.
  public let details: String?

  /// Creates validation error context.
  public init(path: String, reason: ValidationErrorReason, details: String? = nil) {
    self.path = path
    self.reason = reason
    self.details = details
  }
}

/// Structured write failure payload.
public struct WriteErrorContext: Sendable {
  /// Absolute target path of the failed operation.
  public let targetPath: String
  /// Active write mode.
  public let mode: ResourceWriteMode
  /// Write failure category.
  public let reason: WriteErrorReason
  /// Optional human-readable details.
  public let details: String?

  /// Creates write error context.
  public init(
    targetPath: String,
    mode: ResourceWriteMode,
    reason: WriteErrorReason,
    details: String? = nil
  ) {
    self.targetPath = targetPath
    self.mode = mode
    self.reason = reason
    self.details = details
  }
}

/// Unified top-level error for parse, validation and write phases.
public enum ResourceGeneratorError: Error {
  /// Parse-phase failure.
  case parse(ParseErrorContext)
  /// Validation-phase failure.
  case validation(ValidationErrorContext)
  /// Write-phase failure.
  case write(WriteErrorContext)
}

extension ResourceGeneratorError: LocalizedError {
  /// Localized human-readable error text including path context.
  public var errorDescription: String? {
    switch self {
      case .parse(let context):
        return
          "parse error [\(context.assetKind.rawValue)] at '\(context.nodePath)' in catalog '\(context.catalogPath)': \(context.underlyingErrorDescription)"
      case .validation(let context):
        let details = context.details.map { ": \($0)" } ?? ""
        return "validation error [\(context.reason.rawValue)] at '\(context.path)'\(details)"
      case .write(let context):
        let details = context.details.map { ": \($0)" } ?? ""
        return
          "write error [\(context.reason.rawValue)] at '\(context.targetPath)' (mode=\(context.mode.rawValue))\(details)"
    }
  }
}
