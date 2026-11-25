# GamingXDev

Open `GamingXDev.code-workspace` in VS Code for the GamingXDev workspace. It
contains separate Swift packages:

- **GamingUI** — reusable SwiftUI/UIKit interface module and its tests.
- **GamingApp** — example iOS app that consumes GamingUI.

The package names intentionally remain distinct from the workspace name.

## Build and test

The packages import Apple platform frameworks (`SwiftUI` and `UIKit`). On
Linux, plain `swift test` cannot build them because those frameworks are not
part of the Linux SDK. Use xtool for Apple-platform builds on Linux. On macOS,
`swift test` can run where the selected Apple SDK and destination support the
package.

See [the iOS build research](docs/ios-build-research.md) for the Xcode,
SwiftPM, xtool, and x86Sim comparison and the Linux simulator experiment.
