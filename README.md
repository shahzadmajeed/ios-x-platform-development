# GamingXDev

Open `GamingXDev.code-workspace` in VS Code for the GamingXDev workspace. It
contains separate Swift packages:

- **GamingUI** — reusable SwiftUI/UIKit interface module and its tests.
- **GamingApp** — example iOS app that consumes GamingUI.
- **NativeWidgetProbe** — a native Xcode project with an app, a WidgetKit
  extension, and the GamingUI test target.

The package names intentionally remain distinct from the workspace name.

## Build and test

The packages import Apple platform frameworks (`SwiftUI` and `UIKit`). On
Linux, plain `swift test` cannot build them because those frameworks are not
part of the Linux SDK. Use xtool for Apple-platform builds on Linux. On macOS,
`swift test` can run where the selected Apple SDK and destination support the
package.

`Examples/NativeWidgetProbe/NativeWidgetProbe.xcodeproj` is a native Xcode
project experiment with a WidgetKit extension and the GamingUI test target.
Its app and extension build with xtool beta, and the existing test passes on
the x86Sim runtime. See the experiment report for commands, evidence, and
limitations.

See [the iOS build research](docs/ios-build-research.md) for the Xcode,
SwiftPM, xtool, and x86Sim comparison and the Linux simulator experiment.
See the [native widget experiment](docs/experiments/xtool-native-widget-probe.md)
for reproducible xtool beta build, install, and test results.
See the [Firefox iOS build attempt](docs/experiments/xtool-firefox-ios.md)
for results against a large real-world Xcode project.
