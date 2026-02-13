import Foundation

/// Plugin contract to produce resources dynamically.
public protocol ResourcePlugin: Sendable {
  /// Stable lookup key in ``ResourcePluginRegistry``.
  var key: String { get }
  /// Produces resources on demand.
  func makeResources() throws -> [any Resource]
}

/// Runtime registry for resource plugins.
public struct ResourcePluginRegistry: Sendable {
  private var plugins: [String: any ResourcePlugin]

  /// Creates a registry and pre-registers plugins.
  public init(plugins: [any ResourcePlugin] = []) {
    self.plugins = Dictionary(uniqueKeysWithValues: plugins.map { ($0.key, $0) })
  }

  /// Registers or replaces a plugin for its key.
  public mutating func register(_ plugin: any ResourcePlugin) {
    plugins[plugin.key] = plugin
  }

  /// Resolves resources for a registered plugin key.
  public func resources(for key: String) throws -> [any Resource] {
    guard let plugin = plugins[key] else {
      throw ResourcePluginRegistryError.pluginNotFound(key)
    }
    return try plugin.makeResources()
  }

  /// Returns all plugin keys in deterministic order.
  public func allKeys() -> [String] {
    plugins.keys.sorted()
  }
}

/// Errors thrown by ``ResourcePluginRegistry``.
public enum ResourcePluginRegistryError: Error, Equatable {
  /// No plugin exists for the requested key.
  case pluginNotFound(String)
}
