import Foundation

/// Result builder that composes `AssetNode` values into catalogs and groups.
@resultBuilder
public enum AssetBuilder {
  /// Combines sequential builder components.
  public static func buildBlock(_ components: [any AssetNode]...) -> [any AssetNode] {
    components.flatMap { $0 }
  }

  /// Wraps a single node expression.
  public static func buildExpression(_ expression: any AssetNode) -> [any AssetNode] {
    [expression]
  }

  /// Passes through prebuilt node arrays.
  public static func buildExpression(_ expression: [any AssetNode]) -> [any AssetNode] {
    expression
  }

  /// Supports `if` blocks without `else`.
  public static func buildOptional(_ component: [any AssetNode]?) -> [any AssetNode] {
    component ?? []
  }

  /// Supports first conditional branch.
  public static func buildEither(first component: [any AssetNode]) -> [any AssetNode] {
    component
  }

  /// Supports second conditional branch.
  public static func buildEither(second component: [any AssetNode]) -> [any AssetNode] {
    component
  }

  /// Supports `for` loops in builders.
  public static func buildArray(_ components: [[any AssetNode]]) -> [any AssetNode] {
    components.flatMap { $0 }
  }
}
