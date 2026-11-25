# xtool beta: Firefox iOS project attempt

**Run:** 2026-11-25, WSL2 Linux x86-64
**Project:** `mozilla-mobile/firefox-ios`, commit
`98a238d026df8b789ab6a1c786e19a0423b4be86`
**xtool:** 2.0.0-beta.1
**Target:** `arm64-apple-ios-simulator`

This tests Mozilla's actual native Xcode project, not the small
[NativeWidgetProbe](xtool-native-widget-probe.md). The Firefox project has 22
native targets, including 6 app extensions, 15 shell-script build phases, and
17 resolved Swift package pins. The selected shared scheme is `Firefox`.

## Attempt

```sh
xtool dev build --scheme Firefox \
  --triple arm64-apple-ios-simulator
```

The first attempt resolved dependencies but exhausted the 7.6 GB `/tmp`
filesystem while extracting large binary frameworks. I moved the temporary
checkout and its generated package cache to disk-backed storage, then retried;
this removed the storage constraint.

**Build failed.** SwiftBuild planned the project, but resource-tool invocations
could not launch. It attempted to run `actool` and `ibtool` from the Firefox
source root, where those executables do not exist. The SDK does contain xtool's
emulated versions under `Xcode.app/Contents/Developer/usr/bin/`, but setting
`DEVELOPER_DIR` to that tool directory did not change the resolved paths.
Pointing `DEVELOPER_DIR` at the SDK's Developer directory instead caused
duplicate platform-registration errors during build-system initialization.
The final build log also reported `failed to read asset tags`.

The build did not produce a Firefox app or test bundle. No tests were run, and
there was nothing to install or launch in x86Sim. This is a concrete blocker
for this beta/SDK configuration; it does not establish that Firefox can never
build with xtool or a later release.

## Result

The NativeWidgetProbe success is not evidence that a large, real-world Xcode
project will build. For this Firefox revision, the observed blocker is
SwiftBuild's resource-tool path resolution before a successful app build.
Compilation beyond this stage, extension embedding, the scheme's test plans,
simulator installation, and runtime behavior remain unverified.

The Firefox source checkout and verbose build logs remain outside this
repository; only this experiment summary is included here.
