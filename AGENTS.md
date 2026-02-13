# AGENTS.md

Guidance for coding agents and contributors working in this repository.

## Maintainer

- Owner: Joel Fejzulahi (`@JFej`)

## Scope

- This repo is a Swift Package.
- Package name: `swift-resource-generator`
- Library product/module name: `ResourceGenerator`

## Working style

- Be direct, short, and technical.
- Prefer root-cause fixes over patches.
- Keep changes small and reviewable.
- Keep files readable; split when files become too large.

## Code conventions

- Keep file names aligned with primary type names.
- Follow existing architecture and naming style.
- Avoid unnecessary dependencies.
- Use typed errors where appropriate (`throws(ResourceGeneratorError)`).
- Do not expose internal-only APIs unless intentional.

## Tests and validation

Run this full gate before handoff:

```bash
swift format -i -r Sources Tests Package.swift
swift test
swift test -c release
```

If fixing a bug, add a regression test when it fits.

## Documentation

- Update `README.md` when public API or usage changes.
- Update DocC content in `Sources/ResourceGenerator/ResourceGenerator.docc/` when behavior or API changes.

## CI

- Keep local commands aligned with CI workflow.
- If CI fails, reproduce locally, fix, and re-run full gate.

## Git safety

- Prefer safe commands (`status`, `diff`, `log`).
- Never run destructive commands (`reset --hard`, `clean`, mass delete) unless explicitly requested.
- Do not revert unrelated user changes.
- If you encounter unexpected conflicting edits in the same files, stop and ask.

## Release notes

- Project is pre-`1.0.0`; breaking changes are allowed.
- Still document notable API changes clearly in PR descriptions and docs.
