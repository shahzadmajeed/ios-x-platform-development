# Building iOS apps: Xcode, SwiftPM, xtool, and x86Sim

**Research snapshot:** 2026-11-24  
**Host context:** Linux x86-64 under WSL2  
**Installed at the start of this evaluation:** xtool 1.24.0 and x86Sim 0.5.3

## Executive summary

For a large, mixed-language iOS app with many Xcode targets, custom build
phases, and extensions, Xcode and `xcodebuild` on macOS remain the reference
build and test environment. xtool 2.0.0-beta.1 is the first xtool release in
this investigation to build `.xcodeproj` and `.xcworkspace` files directly,
but it is a beta and its Linux workflow has known missing Apple build tools.
The sample in this workspace is small and cannot establish compatibility for
an enterprise project.

x86Sim is a simulator/runtime layer, not a peer build system. It can run
compatible simulator apps and test bundles on Linux, but it does not make
every Xcode project buildable on Linux.

## Version snapshot

| Tool | Version | Notes |
|---|---|---|
| Xcode / `xcodebuild` | Requires macOS; version depends on the selected Xcode installation | Apple’s supported IDE and command-line build/test toolchain. |
| xtool stable | 1.24.0 | The latest stable release found in the release listing. Primarily uses SwiftPM workflows. |
| xtool beta | 2.0.0-beta.1 | Published 2026-11-16. Adds direct Xcode project/workspace support using SwiftBuild. Release explicitly offers no stability guarantees. |
| x86Sim installed here | 0.5.3 | Linux simulator currently has an iOS 27.2 runtime and an iPhone 18 Pro Max device configured. |
| x86Sim upstream reference | 0.6.0 | The documentation and converter limits below refer to this release; it was not the version installed in this environment. |

Version data is a snapshot, not a promise that these remain the latest
releases.

## Xcode / xcodebuild, SwiftPM, and xtool

**Legend:** ✅ documented support; ◐ partial, beta-only, or dependent on
project-specific validation; ❌ not available in that workflow.

| Area | Xcode / `xcodebuild` on macOS | SwiftPM (host-dependent) | xtool on Linux (stable and beta) |
|---|---|---|---|
| Native `.xcodeproj` / `.xcworkspace` builds | ✅ Native projects, workspaces, schemes, targets, configurations, and command-line builds. | ❌ Consumes `Package.swift` manifests, not Xcode projects or workspaces. | ◐ Direct project/workspace builds are **beta-only** in 2.0.0-beta.1. Stable 1.24.0 is SwiftPM-oriented. |
| Package dependencies | ✅ Native SwiftPM integration. On macOS, SwiftPM can compile Apple-platform code when the selected Apple SDK supports it. | ✅ Resolves and builds Swift packages. It is not limited to pure Swift: package targets can also use C, C++, and Objective-C where the toolchain and platform support them. | ✅ Stable and beta use SwiftPM for package resolution. Compatibility still depends on manifests, plugins, macros, binary artifacts, and host assumptions. |
| Many dependencies / targets | ✅ No small tool-imposed count limit; real build cost and compatibility depend on the project. | ✅ No documented small fixed count limit for package targets; the package graph and dependencies determine practical compatibility. | ◐ No documented fixed count limit, but no evidence here validates 50+ dependencies or a 200-target graph. Beta project support is not enterprise-scale certification. |
| Swift, Objective-C, C, and C++ | ✅ Native Apple toolchains support mixed-language projects. | ◐ Supported package target languages depend on the host compiler and platform SDK. Linux SwiftPM can build compatible C-family targets, but not Apple-framework-dependent targets without an Apple SDK. | ◐ Compatible SwiftPM C-family targets are possible; direct Xcode-project handling is beta-only and needs validation against the actual target graph. |
| Apple platform frameworks on Linux | ✅ Apple SDKs and frameworks are available on macOS. | ❌ Plain Linux SwiftPM lacks Apple SDKs/frameworks such as SwiftUI and UIKit. On macOS, SwiftPM can compile package code that imports Apple frameworks when the selected SDK supports it. | ✅ xtool supplies an Apple-platform toolchain/SDK workflow for builds on Linux; individual frameworks and resources still need validation. |
| CocoaPods and generated workspaces | ✅ `xcodebuild` can build a compatible generated workspace when dependency tooling is installed and the project is configured. | ❌ CocoaPods workspaces and Xcode-generated target graphs are outside SwiftPM’s project model. | ◐ Beta workspace support does not establish CocoaPods compatibility. The separate x86Sim converter explicitly warns about CocoaPods. |
| Build phases, scripts, build rules | ✅ Xcode project phases and scripts execute in the macOS build environment. | ◐ SwiftPM build-tool and command plugins can add package build steps, but they are not arbitrary Xcode build phases. | ◐ Stable package builds do not reproduce arbitrary Xcode project phases. Beta uses SwiftBuild for project builds, but scripts requiring unavailable Apple tools remain a Linux risk. The x86Sim converter does not support run-script phases. |
| Build settings and `.xcconfig` | ✅ Native Xcode settings, configurations, and command-line overrides. | ❌ No Xcode target build-settings or `.xcconfig` model. | ◐ Beta project support exists, but validate project-specific and unmapped settings. The x86Sim converter warns about settings it cannot map. |
| Asset catalogs, storyboards, app intents | ✅ Apple’s build tools support these inputs. | ◐ Can build package resources supported by the active SDK, but does not itself provide the full Xcode app-resource compilation and packaging workflow. | ◐ The beta release specifically calls out Linux gaps for asset catalogs, storyboards, and App Intents. |
| App extensions and widgets | ✅ Native extension targets, embedding, signing, and Apple simulator/device workflows. | ❌ SwiftPM can build modules but does not provide the complete extension-target, embedding, signing, and deployment workflow. | ◐ Stable xtool documents a SwiftPM extension workflow. Beta project support is not a guarantee for every extension type; xtool’s guide reports ExtensionKit limitations. |
| AppDelegate / SceneDelegate and app code | ✅ Built and run through Apple’s toolchain and simulator/device environments. | ◐ Code can be part of a package target when its Apple frameworks and SDK are available; SwiftPM alone does not provide the full iOS app run/deploy workflow. | ✅ Code can build when supported by the project path, compiler, and SDK. Runtime behavior depends on the simulator used separately. |
| Signing and distribution | ✅ Native signing, provisioning, archive, and export workflows. | ❌ No built-in iOS signing, provisioning, archive, or App Store export workflow. | ◐ xtool has Apple Developer Services and signing workflows. Validate project signing, extension entitlements, and archive output for the app. |
| Tests | ✅ `xcodebuild test`, `build-for-testing`, and `test-without-building` support schemes and destinations. | ✅ `swift test` runs package test targets where the host platform and dependencies support them. Linux cannot run this app’s Apple-framework-dependent tests with plain SwiftPM. | ◐ xtool’s `dev` CLI builds/runs apps but does not expose an Xcode-equivalent `test` action. x86Sim 0.6 documents `x86sim test --spm` for SwiftPM package tests; Xcode-project test bundles still need Xcode’s build system. |
| Simulator install/run | ✅ Apple Simulator and device workflows integrate with Xcode. | ❌ SwiftPM does not create/manage an iOS simulator or install an app into one. | ◐ Build via xtool, then install/run with a separate simulator such as x86Sim; `xtool dev run --simulator` is documented as macOS-only. |
| IDE, previews, debugging, Instruments | ✅ Xcode provides previews, LLDB, Instruments, and related workflows. | ❌ SwiftPM is a package manager/build/test tool, not an IDE or simulator. | ❌ xtool is a CLI/build tool, not the Xcode IDE. Beta hot reload is documented for macOS, not Linux. |
| Host platform | ❌ Apple’s Xcode toolchain requires macOS. | ✅ SwiftPM runs on Linux and macOS, subject to the installed compiler, SDKs, and package requirements. | ✅ xtool targets Linux and other supported hosts, with Apple SDK material supplied separately. |

**Important distinction:** SwiftPM itself is not restricted to pure-Swift
projects. The specific Linux limitation is that plain Linux SwiftPM does not
have Apple’s iOS/macOS SDK frameworks. This workspace’s Linux `swift test`
attempt stopped at `import SwiftUI` with `error: no such module 'SwiftUI'`;
the source also imports `UIKit`, which is likewise an Apple-only framework in
this host setup. On macOS, SwiftPM can compile package targets that use Apple
frameworks when the selected SDK supports them. Full iOS app packaging,
signing, simulator deployment, and Xcode-project workflows remain separate
capabilities.

Apple’s [Xcode overview](https://developer.apple.com/xcode/) describes its
development, simulator, testing, debugging, and profiling tools. Apple’s
[command-line build FAQ](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
documents `xcodebuild` operations for projects, workspaces, targets, tests,
archives, and export. The [build settings reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
describes the breadth of Xcode build settings, including extension and
resource-related settings.

xtool’s [2.0.0-beta.1 release notes](https://github.com/xtool-org/xtool/releases/tag/2.0.0-beta.1)
state that project/workspace support is new and beta, that SwiftPM remains in
the package-resolution path, and that Linux lacks some tools including asset
catalog, App Intents, and storyboard support. The
[1.24.0 stable release](https://github.com/xtool-org/xtool/releases/tag/1.24.0)
is the stable-version reference.

## x86Sim: separate simulator/runtime layer

| Area | x86Sim capability and caveat |
|---|---|
| Role | Runs Apple simulator runtimes on x86-64 Linux. It complements a builder; it is not a full Apple-equivalent Xcode build system. |
| Apps | Runs compatible arm64 simulator `.app` builds. It can also convert eligible device-built apps for simulator use; this is not a guarantee for every `.ipa`. |
| Devices and runtimes | Provides Linux device/runtime management and GUI/CLI workflows. This environment has iOS 27.2 configured. |
| Tests | Can run XCTest/XCUITest bundles. x86Sim’s docs say Xcode-project test bundles need to be built on a Mac; Swift package tests can be built on Linux. |
| Automation and debugging | Documents CLI/browser automation, accessibility interaction, LLDB, logs, screenshots, and CPU profiling. |
| Differences from Apple’s simulator | Uses arm64-to-x86-64 translation and translates Metal to Vulkan/software paths. Some hardware/services are missing; it is not a production performance or security-validation substitute. |

x86Sim’s [0.6.0 README](https://github.com/x86sim/x86sim/blob/v0.6.0/README.md)
and [parity matrix](https://github.com/x86sim/x86sim/blob/v0.6.0/docs/PARITY.md)
are project-reported capability documentation, not certification of this app.
The 0.6.0 README documents `x86sim test --spm` for building and running SwiftPM
tests on Linux; this command is not present in the 0.5.3 CLI installed here.
Its pinned [Xcode-project converter source](https://github.com/x86sim/omarchy-apple-dev/blob/e05871484b8da0aa8c7a70c8a402e5332264951a/tools/xcodeproj2xtool.py)
generates an adapter for one selected iOS app target. It warns about
unsupported CocoaPods, Objective-C source files, run-script phases, Icon
Composer `.icon` assets, and unmapped settings; it can include certain
embedded extensions.

## Results on this Linux host

The workspace originally contained Swift package manifests, but no native
`.xcodeproj` or `.xcworkspace`. xtool 2.0.0-beta.1 generated a small
`GamingApp` Xcode workspace from the app's Swift package. The resulting shared
scheme has an empty `Testables` list; it does not include the separate test
target in the root `GamingUI` package.

The following beta build succeeded:

```sh
xtool dev build --scheme GamingApp-App \
  --triple arm64-apple-ios-simulator --verbose
```

SwiftBuild reported **Build completed** and produced an arm64 simulator app.
It also emitted warnings that the Linux `ld64.lld` version does not support
linking for the iOS Simulator platform and that the `gamingapp` package
dependency was unused by a target. A successful build despite the linker
warning is useful evidence for this sample, not proof that the output is
equivalent to an Apple `xcodebuild` result.

The app was installed and launched on the configured iPhone 18 Pro Max /
iOS 27.2 x86Sim device (bundle ID `com.example.GamingApp`). The running screen
showed the interactive Gaming Hub. This verifies build, install, and launch for
this sample.

The existing root-package test target was **not run successfully**:

- Plain Linux `swift test` stopped at `import SwiftUI` with
  `error: no such module 'SwiftUI'`. The source also imports `UIKit`, but
  compilation stopped at the first missing framework.
- xtool 2.0.0-beta.1 exposes `dev build` and `dev run`, but no test action.
- The generated app workspace contains no testables. The separate root test
  target therefore was not included in that app scheme.
- The x86Sim 0.6 documentation offers `x86sim test --spm`, but its Linux
  development status here says the iOS test SDK is not built and requires
  Xcode.xip; its test runner also could not use this installed 0.5.3
  simulator data through the temporary 0.6 AppImage.

**Result:** app build/install/launch passed for the sample; “all tests passed”
is not established. Running the package tests needs a working Apple-platform
test SDK and simulator test runner (or Xcode on macOS), and a real Xcode
project's test bundles still need the project’s actual build graph.

## Implications for this workspace

This workspace contains a `GamingUI` Swift package with a small test target
and a separate `GamingApp` Swift package. It does not start as a native
`.xcodeproj` or `.xcworkspace`, and it is not representative of a large
enterprise app. A successful build here would prove only the tested sample
path, not compatibility with 50+ mixed dependencies, 200+ targets, custom
phases, or a complex extension graph.

For an enterprise project, the prudent path is:

1. Keep Xcode/xcodebuild on macOS as the baseline for complete project builds,
   tests, signing, and release archives.
2. Evaluate xtool 2.0 beta against the real workspace, recording each target,
   dependency, build phase, extension, resource tool, and test result.
3. Use x86Sim only after producing a compatible simulator build, as an
   additional Linux functional-testing environment.
4. Verify release builds and device-specific behavior with Apple’s tooling and
   real devices.
