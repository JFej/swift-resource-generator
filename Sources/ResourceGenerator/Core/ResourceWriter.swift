import Foundation

/// Writes a ``GenerationPlan`` to disk using configurable conflict behavior.
struct ResourceWriter {
  private let fileManager: FileManager

  /// Creates a writer with an injectable file manager for tests.
  init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
  }

  /// Writes a plan into `outputURL`.
  ///
  /// - Returns: A report with diff and write counters.
  /// - Throws: ``ResourceGeneratorError/write(_:)`` when any filesystem operation fails.
  @discardableResult
  func write(
    plan: GenerationPlan,
    to outputURL: URL,
    options: ResourceWriteOptions
  ) throws(ResourceGeneratorError) -> ResourceWriteReport {
    let diff: ResourceDiff
    do {
      diff = try plan.diff(against: outputURL, fileManager: fileManager)
    } catch let error as ResourceGeneratorError {
      throw error
    } catch {
      throw ResourceGeneratorError.write(
        .init(
          targetPath: outputURL.path,
          mode: options.mode,
          reason: .readExistingFileFailed,
          details: String(describing: error)
        )
      )
    }

    if options.dryRun {
      return ResourceWriteReport(
        dryRun: true,
        diff: diff,
        writtenFilesCount: 0,
        skippedFilesCount: diff.unchangedFiles.count
      )
    }

    do {
      try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true)
    } catch {
      throw ResourceGeneratorError.write(
        .init(
          targetPath: outputURL.path,
          mode: options.mode,
          reason: .createDirectoryFailed,
          details: String(describing: error)
        )
      )
    }

    var writtenFilesCount = 0
    var skippedFilesCount = 0

    for entry in plan.entries {
      let targetURL = outputURL.appendingPathComponent(entry.normalizedPath)

      switch entry.kind {
        case .directory:
          do {
            try fileManager.createDirectory(at: targetURL, withIntermediateDirectories: true)
          } catch {
            throw ResourceGeneratorError.write(
              .init(
                targetPath: targetURL.path,
                mode: options.mode,
                reason: .createDirectoryFailed,
                details: String(describing: error)
              )
            )
          }
        case .file(let data):
          let parentDirectory = targetURL.deletingLastPathComponent()
          do {
            try fileManager.createDirectory(at: parentDirectory, withIntermediateDirectories: true)
          } catch {
            throw ResourceGeneratorError.write(
              .init(
                targetPath: parentDirectory.path,
                mode: options.mode,
                reason: .createDirectoryFailed,
                details: String(describing: error)
              )
            )
          }

          if fileManager.fileExists(atPath: targetURL.path) {
            let existingData: Data
            do {
              existingData = try Data(contentsOf: targetURL)
            } catch {
              throw ResourceGeneratorError.write(
                .init(
                  targetPath: targetURL.path,
                  mode: options.mode,
                  reason: .readExistingFileFailed,
                  details: String(describing: error)
                )
              )
            }

            if options.skipUnchangedFiles && existingData == data {
              skippedFilesCount += 1
              continue
            }

            switch options.mode {
              case .failIfExists:
                throw ResourceGeneratorError.write(
                  .init(targetPath: targetURL.path, mode: options.mode, reason: .fileAlreadyExists)
                )
              case .mergePreferExisting:
                skippedFilesCount += 1
                continue
              case .overwrite, .mergePreferGenerated:
                do {
                  try fileManager.removeItem(at: targetURL)
                } catch {
                  throw ResourceGeneratorError.write(
                    .init(
                      targetPath: targetURL.path,
                      mode: options.mode,
                      reason: .removeExistingFileFailed,
                      details: String(describing: error)
                    )
                  )
                }
            }
          }

          do {
            try data.write(to: targetURL)
          } catch {
            throw ResourceGeneratorError.write(
              .init(
                targetPath: targetURL.path,
                mode: options.mode,
                reason: .writeFileFailed,
                details: String(describing: error)
              )
            )
          }

          writtenFilesCount += 1
      }
    }

    return ResourceWriteReport(
      dryRun: false,
      diff: diff,
      writtenFilesCount: writtenFilesCount,
      skippedFilesCount: skippedFilesCount
    )
  }
}
