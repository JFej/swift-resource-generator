import Foundation

/// Result builder for image-set variant declarations.
@resultBuilder
public enum ImageVariantBuilder {
  /// Combines sequential builder components.
  public static func buildBlock(
    _ components: [AssetImageSet.VariantSource]...
  ) -> [AssetImageSet.VariantSource] {
    components.flatMap { $0 }
  }

  /// Wraps a single variant expression.
  public static func buildExpression(
    _ expression: AssetImageSet.VariantSource
  ) -> [AssetImageSet.VariantSource] {
    [expression]
  }

  /// Passes through prebuilt variant arrays.
  public static func buildExpression(
    _ expression: [AssetImageSet.VariantSource]
  ) -> [AssetImageSet.VariantSource] {
    expression
  }

  /// Supports `if` blocks without `else`.
  public static func buildOptional(
    _ component: [AssetImageSet.VariantSource]?
  ) -> [AssetImageSet.VariantSource] {
    component ?? []
  }

  /// Supports first conditional branch.
  public static func buildEither(
    first component: [AssetImageSet.VariantSource]
  ) -> [AssetImageSet.VariantSource] {
    component
  }

  /// Supports second conditional branch.
  public static func buildEither(
    second component: [AssetImageSet.VariantSource]
  ) -> [AssetImageSet.VariantSource] {
    component
  }

  /// Supports `for` loops in builders.
  public static func buildArray(
    _ components: [[AssetImageSet.VariantSource]]
  ) -> [AssetImageSet.VariantSource] {
    components.flatMap { $0 }
  }
}
