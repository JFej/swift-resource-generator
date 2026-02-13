import Foundation

/// A single output entry produced by a resource.
public struct GeneratedEntry: Sendable {
  /// Entry payload kind.
  public enum Kind: Sendable {
    /// Directory marker.
    case directory
    /// File payload.
    case file(Data)
  }

  /// Relative path inside the output root.
  public let relativePath: String
  /// Directory or file payload.
  public let kind: Kind

  /// Creates a new generated entry.
  public init(relativePath: String, kind: Kind) {
    self.relativePath = relativePath
    self.kind = kind
  }

  /// Convenience constructor for directory entries.
  static func directory(_ relativePath: String) -> Self {
    .init(relativePath: relativePath, kind: .directory)
  }

  /// Convenience constructor for file entries.
  static func file(_ relativePath: String, _ data: Data) -> Self {
    .init(relativePath: relativePath, kind: .file(data))
  }

  /// Path normalized to forward slashes.
  var normalizedPath: String {
    relativePath.replacingOccurrences(of: "\\", with: "/")
  }

  /// `true` when this entry is a directory marker.
  var isDirectory: Bool {
    if case .directory = kind {
      return true
    }
    return false
  }

  /// File payload when `kind == .file`; otherwise `nil`.
  var fileData: Data? {
    if case .file(let data) = kind {
      return data
    }
    return nil
  }
}
