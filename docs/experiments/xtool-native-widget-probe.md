# xtool beta: native Xcode project with a widget

**Run:** 2026-11-25, WSL2 Linux x86-64
**xtool:** 2.0.0-beta.1, the latest published prerelease checked on this date
**Simulator:** x86Sim 0.5.3, iPhone 18 Pro Max / iOS 27.2
**Test runner:** x86Sim 0.6.0

The workspace did not contain a native Xcode project, so this reproducible
probe adds one at
[`Examples/NativeWidgetProbe/`](../../Examples/NativeWidgetProbe/). Its shared
scheme builds three targets:

- `NativeWidgetProbe`, a SwiftUI app
- `NativeWidgetExtension`, a WidgetKit app extension embedded in the app
- `GamingUITests`, which uses the existing local `GamingUI` and `GamingPreview`
  Swift package products and the workspace's existing test source

## Build

From `Examples/NativeWidgetProbe/`, with xtool 2.0.0-beta.1 on `PATH`:

```sh
xtool dev build --scheme NativeWidgetProbe \
  --triple arm64-apple-ios-simulator
```

**Passed.** SwiftBuild reported `Build completed` and produced all three
products: `NativeWidgetProbe.app`, its embedded
`PlugIns/NativeWidgetExtension.appex`, and `GamingUITests.xctest`. This is a
direct build of a checked-in `.xcodeproj`, not xtool's SwiftPM-to-Xcode-project
conversion.

The build emitted warnings that this Linux `ld64.lld` does not support iOS
Simulator linking and about legacy headermap settings. The successful output
is evidence for this small fixture only; the linker warning means it is not an
Apple-toolchain equivalence claim.

## Install and launch

The app and extension installed successfully on the running iOS 27.2 x86Sim
device. The app launched and displayed “Native widget project.” Evidence:

- [App running in the simulator](native-widget-probe-running.png)
- [Probe app installed on the simulator Home Screen](native-widget-probe-home.png)

The x86Sim install and launch commands operate on its device runtime but do
not open a visible window. Start the separate GTK viewer with `x86sim view`.
On this WSL2 host, the viewer initially failed because GTK 4 introspection
support was missing; installing `gir1.2-gtk-4.0` enabled it. This is x86Sim's
Linux viewer, not Apple's macOS Simulator.app.

The widget extension was compiled, embedded, and accepted by the simulator's
installer. The widget was **not added to a Home Screen**, so this experiment
does not claim that WidgetKit rendered or ran the widget in x86Sim.

## Tests

The native project includes the existing `GamingUITests` target, with one Swift
Testing test. xtool built its `.xctest` bundle as part of the scheme. x86Sim
0.6.0's runner then executed that bundle on the iOS 27.2 device using the
XCTest platform files from xtool's installed Darwin SDK. `llvm-lipo` was
required on `PATH` (`llvm-22` was installed on this host).

**Passed: 1 test, 0 failures, 0 skipped.**

`consumerModuleUsesGamingUIModule()` passed in 0.033 seconds; the complete
runner session took 6.032 seconds. See [the saved test summary](test-results.json)
and [JUnit report](test-results.xml).

This is the workspace's one existing test, built through the native project
and run on the simulator. It is not evidence that an unprovided enterprise
app's complete test suite or UI tests will work.

To repeat the test on this host after the xtool build, set up x86Sim's device
paths and run:

```sh
export PATH="/usr/lib/llvm-22/bin:$PATH"
export X86SIM_ROOT="$HOME/.local/share/x86sim/app/0.6.0"
export X86SIM_DEVICE="$HOME/.local/share/x86sim/app/0.5.3/var/device-a64-iphone-18-pro-max-ios-27"
export X86SIM_RUNTIME="$HOME/.local/share/x86sim/app/0.5.3/runtimes/ios-27.2-24B8117-arm64/RuntimeRoot"
export X86SIM_STATE="$HOME/.local/share/x86sim/app/0.5.3/var/run-a64-iphone-18-pro-max-ios-27"
export X86SIM_PREFIX="$HOME/.local/share/x86sim/darling-prefix"
export X86SIM_DPREFIX="$HOME/scratch/x86sim/a64prefix-iphone-18-pro-max-ios-27-v2"
export X86SIM_SCRATCH="$HOME/scratch/x86sim"
export SIMFB_RING_LINUX="/run/user/1000/x86sim-a64-iphone-18-pro-max-ios-27-simfb.ring"

"$X86SIM_ROOT/cli/x86sim" test \
  --test-bundle "$PWD/xtool/.xtool-tmp/DerivedData/Products/Debug-iphonesimulator/GamingUITests.xctest" \
  --platform "$HOME/.config/xtool/darwin.xtoolsdk/Xcode.app/Contents/Developer/Platforms" \
  --verbose
```

## Limits and next validation

- The original workspace has only one test. “All tests passed” here means that
  one test, not a larger suite.
- x86Sim's accessibility snapshot tool from 0.6.0 could not read this 0.5.3
  device, so the widget was not placed or visually exercised.
- No real company project was present. This fixture does not test CocoaPods,
  Objective-C dependencies, dozens of packages, hundreds of targets, custom
  shell phases, notification extensions, signing, or production entitlements.
- The prior plain `swift test` command on Linux still fails at
  `import SwiftUI`; the successful test used the native Xcode project build
  and x86Sim test runner instead.

To validate a real app, build its actual project/workspace and test scheme with
the same beta, then separately verify every embedded extension and widget on
Apple's simulator or a device.
