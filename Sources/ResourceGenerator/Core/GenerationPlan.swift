import Foundation

/// Fully materialized output of a generation run.
public struct GenerationPlan: Sendable {
  /// Entries to write, optionally deterministically ordered.
  public let entries: [GeneratedEntry]

  /// Creates a generation plan.
  ///
  /// - Parameters:
  ///   - entries: Generated entries from resources.
  ///   - deterministicOrdering: Sorts entries for stable output.
  public init(entries: [GeneratedEntry], deterministicOrdering: Bool = true) {
    if deterministicOrdering {
      self.entries = entries.sorted(by: Self.sortEntries(lhs:rhs:))
    } else {
      self.entries = entries
    }
  }

  /// Calculates changes relative to an existing output directory.
  public func diff(
    against outputURL: URL, fileManager: FileManager = .default
  ) throws -> ResourceDiff {
    var createdDirectories: [String] = []
    var createdFiles: [String] = []
    var updatedFiles: [String] = []
    var unchangedFiles: [String] = []

    for entry in entries {
      let targetURL = outputURL.appendingPathComponent(entry.normalizedPath)
      switch entry.kind {
        case .directory:
          if !fileManager.fileExists(atPath: targetURL.path) {
            createdDirectories.append(entry.normalizedPath)
          }
        case .file(let data):
          if fileManager.fileExists(atPath: targetURL.path) {
            let existing = try Data(contentsOf: targetURL)
            if existing == data {
              unchangedFiles.append(entry.normalizedPath)
            } else {
              updatedFiles.append(entry.normalizedPath)
            }
          } else {
            createdFiles.append(entry.normalizedPath)
          }
      }
    }

    return ResourceDiff(
      createdDirectories: createdDirectories.sorted(),
      createdFiles: createdFiles.sorted(),
      updatedFiles: updatedFiles.sorted(),
      unchangedFiles: unchangedFiles.sorted()
    )
  }

  private static func sortEntries(lhs: GeneratedEntry, rhs: GeneratedEntry) -> Bool {
    if lhs.normalizedPath == rhs.normalizedPath {
      if lhs.isDirectory != rhs.isDirectory {
        return lhs.isDirectory
      }
      return false
    }

    return lhs.normalizedPath < rhs.normalizedPath
  }
}

/// Change summary between a plan and a filesystem location.
public struct ResourceDiff: Sendable {
  /// Directories that do not exist yet.
  public let createdDirectories: [String]
  /// Files that do not exist yet.
  public let createdFiles: [String]
  /// Existing files with changed content.
  public let updatedFiles: [String]
  /// Existing files with identical content.
  public let unchangedFiles: [String]

  /// Creates a diff summary.
  public init(
    createdDirectories: [String],
    createdFiles: [String],
    updatedFiles: [String],
    unchangedFiles: [String]
  ) {
    self.createdDirectories = createdDirectories
    self.createdFiles = createdFiles
    self.updatedFiles = updatedFiles
    self.unchangedFiles = unchangedFiles
  }
}

/// Result of a write execution (or dry-run).
public struct ResourceWriteReport: Sendable {
  /// Indicates whether this report came from dry-run mode.
  public let dryRun: Bool
  /// Planned changes against the target directory.
  public let diff: ResourceDiff
  /// Number of files written to disk.
  public let writtenFilesCount: Int
  /// Number of files skipped due to mode or content identity.
  public let skippedFilesCount: Int

  /// Creates a write report.
  public init(dryRun: Bool, diff: ResourceDiff, writtenFilesCount: Int, skippedFilesCount: Int) {
    self.dryRun = dryRun
    self.diff = diff
    self.writtenFilesCount = writtenFilesCount
    self.skippedFilesCount = skippedFilesCount
  }
}
