# Error Handling

All major failures are represented by ``ResourceGeneratorError``.

## Typed throws

Core APIs use typed throws where only `ResourceGeneratorError` is emitted, for example:

```swift
public func write(
  to outputURL: URL,
  options: ResourceWriteOptions = .default
) throws(ResourceGeneratorError) -> ResourceWriteReport
```

## Error cases

- ``ResourceGeneratorError/parse(_:)`` for parser and decoding failures.
- ``ResourceGeneratorError/validation(_:)`` for invalid names, paths, or asset configuration.
- ``ResourceGeneratorError/write(_:)`` for filesystem write failures.

Each case carries a typed context object with path information.

## Example

```swift
import Foundation
import ResourceGenerator

do {
  try package.write(to: outputURL)
} catch let error as ResourceGeneratorError {
  switch error {
  case .parse(let context):
    print("Parse failed at \(context.nodePath) in \(context.catalogPath)")
  case .validation(let context):
    print("Validation failed at \(context.path): \(context.reason.rawValue)")
  case .write(let context):
    print("Write failed at \(context.targetPath): \(context.reason.rawValue)")
  }
} catch {
  print(error.localizedDescription)
}
```

`LocalizedError` conformance on ``ResourceGeneratorError`` already includes path-aware text suitable for logs.
