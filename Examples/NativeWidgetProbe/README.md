# NativeWidgetProbe

This is a small native Xcode project for checking xtool beta against a real
`.xcodeproj` with an embedded WidgetKit extension and a test target.

From this directory, build with:

```sh
xtool dev build --scheme NativeWidgetProbe \
  --triple arm64-apple-ios-simulator
```

The scheme includes the `GamingUITests` Swift Testing target from the root
package. The tested x86Sim installation and test commands, screenshots,
results, and limitations are documented in
[`docs/experiments/xtool-native-widget-probe.md`](../../docs/experiments/xtool-native-widget-probe.md).
