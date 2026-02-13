import Foundation

/// Top-level container for one generation run.
///
/// Compose resources with `@ResourceBuilder`, inspect the plan/diff, then write.
public struct ResourcePackage: Sendable {
  private let resources: [any Resource]

  /// Creates a package from one or more resources.
  public init(@ResourceBuilder _ resources: () -> [any Resource]) {
    self.resources = resources()
  }

  /// Builds a deterministic generation plan.
  public func plan(
    options: ResourceWriteOptions = .default
  ) throws(ResourceGeneratorError) -> GenerationPlan {
    var entries: [GeneratedEntry] = []
    for resource in resources {
      entries.append(contentsOf: try resource.generateEntries())
    }

    if options.validateBeforeWrite {
      try ResourceValidator.validate(resources: resources, entries: entries)
    }

    return GenerationPlan(entries: entries, deterministicOrdering: options.deterministicOrdering)
  }

  /// Writes all resources to disk and returns a write report.
  @discardableResult
  public func write(
    to outputURL: URL, options: ResourceWriteOptions = .default
  ) throws(ResourceGeneratorError) -> ResourceWriteReport {
    let plan = try plan(options: options)
    return try ResourceWriter().write(plan: plan, to: outputURL, options: options)
  }

  /// Computes a diff against an output directory without writing.
  public func diff(
    against outputURL: URL, options: ResourceWriteOptions = .default
  ) throws -> ResourceDiff {
    let plan = try plan(options: options)
    return try plan.diff(against: outputURL)
  }

  /// Validates names/paths and duplicate entries.
  public func validate() throws(ResourceGeneratorError) {
    _ = try plan(options: .init(dryRun: true))
  }
}
