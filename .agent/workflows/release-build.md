---
description: Analyze, format, and build the Flutter app
---
# Release Build Workflow

This workflow ensures the code is clean and builds the Flutter app.

1. Analyze Dart code for errors or warnings.
// turbo
`dart analyze`

2. Format Dart code according to standards.
// turbo
`dart format lib/`

3. Build the macOS release (or substitute with your preferred target).
// turbo
`flutter build macos`
