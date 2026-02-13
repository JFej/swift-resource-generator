import Foundation

/// Result builder that composes multiple resources into a single package.
@resultBuilder
public enum ResourceBuilder {
  /// Combines sequential builder components.
  public static func buildBlock(_ components: [any Resource]...) -> [any Resource] {
    components.flatMap { $0 }
  }

  /// Wraps a single resource expression.
  public static func buildExpression(_ expression: any Resource) -> [any Resource] {
    [expression]
  }

  /// Passes through prebuilt resource arrays.
  public static func buildExpression(_ expression: [any Resource]) -> [any Resource] {
    expression
  }

  /// Supports `if` blocks without `else`.
  public static func buildOptional(_ component: [any Resource]?) -> [any Resource] {
    component ?? []
  }

  /// Supports `if` and `switch` first branch.
  public static func buildEither(first component: [any Resource]) -> [any Resource] {
    component
  }

  /// Supports `if` and `switch` second branch.
  public static func buildEither(second component: [any Resource]) -> [any Resource] {
    component
  }

  /// Supports `for` loops inside the builder.
  public static func buildArray(_ components: [[any Resource]]) -> [any Resource] {
    components.flatMap { $0 }
  }
}
