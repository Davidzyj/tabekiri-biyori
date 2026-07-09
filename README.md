# たべきり日和

A private, local-only iPhone app for seeing which food should be enjoyed next.

## Requirements

- Xcode 16 or later
- iOS 17 or later
- iPhone only

## Open and run

1. Open `TabekiriBiyori.xcodeproj`.
2. Select the `TabekiriBiyori` scheme and an iPhone simulator.
3. If running on a physical device, select your Apple Developer team for both targets.
4. Register the App Group `group.com.zhouyajie.tabekiribiyori` and enable it for both targets.
5. Build and run.

The app stores food and settings locally. It does not require an account or backend.

## Verification

```sh
plutil -lint TabekiriBiyori/Info.plist
xcodebuild -project TabekiriBiyori.xcodeproj \
  -scheme TabekiriBiyori \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=TrailLevel 6.5' \
  CODE_SIGNING_ALLOWED=NO test
```

See [docs/usage.md](docs/usage.md), [docs/test-cases.md](docs/test-cases.md), and [docs/handoff.md](docs/handoff.md).

