# Engineering Handoff

## Current state

- Product: たべきり日和 / Freshly / 食鲜日记
- Version: 1.0.0 (build 1)
- Bundle ID: `com.zhouyajie.tabekiribiyori`
- Widget ID: `com.zhouyajie.tabekiribiyori.widget`
- App Group: `group.com.zhouyajie.tabekiribiyori`
- Deployment: iOS 17+, iPhone only, portrait, forced light appearance
- Repository: `https://github.com/Davidzyj/tabekiri-biyori`
- Pages: `https://davidzyj.github.io/tabekiri-biyori/`

## Architecture

- SwiftUI app with three tabs: Home, History, Settings.
- SwiftData `FoodItem` is the source of truth.
- Derived urgency sections are computed from the SwiftData query, so mutations refresh the UI.
- Vision performs on-device date OCR.
- UserNotifications schedules one daily local reminder.
- Widget receives a three-item JSON snapshot through App Group UserDefaults.
- `LanguageController` persists an explicit language and injects its locale into SwiftUI.

## Closed user paths

See `docs/product.md`. Add, edit, finish, discard, delete, reminder, language, and web-link paths all persist or produce feedback.

## Important review choices

- `UIUserInterfaceStyle = Light` is set in the actual app plist.
- Pale surfaces use explicit ink colors; placeholders and disabled Save use explicit dark colors.
- Raw support email, URLs, and bundle IDs are not displayed in Settings.
- Web links are user initiated; the app makes no proactive network requests.
- `ITSAppUsesNonExemptEncryption = false` exists in app and widget plists.

## Owner setup still required

1. Register both bundle identifiers in Apple Developer.
2. Register and enable the App Group for both identifiers.
3. Select the owner’s development team and refresh provisioning.
4. Create the App Store Connect app record.
5. Supply review contact phone and final copyright owner.
6. Capture App Store screenshots later; intentionally excluded from this delivery.
7. Archive, upload, complete forms, and submit.

## Regenerating the project

`ruby scripts/generate_project.rb` recreates the Xcode project. Run it after adding source files, then re-check target membership.

## Known boundaries

- OCR recognizes common `YYYY/MM/DD` and `YY/MM/DD` printed formats. The user always confirms.
- Photos are stored locally in SwiftData external storage.
- Widget sharing requires the App Group entitlement to be created in the owner’s developer account.
