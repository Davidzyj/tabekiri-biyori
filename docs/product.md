# たべきり日和 Product Definition

## Product

- Japanese name: たべきり日和
- English name: Freshly
- Simplified Chinese name: 食鲜日记
- Version: 1.0.0
- Bundle ID: `com.zhouyajie.tabekiribiyori`
- Platforms: iPhone only, iOS 17+
- Positioning: a quiet, private food-expiry helper—not an inventory system
- Data: local-only; no account, analytics, ads, tracking, or proactive network access

## Primary user paths

### 1. Add by text

Home → Add → enter food name → choose date/type/location → Save → return Home → item appears in the correct urgency section and a success banner appears.

Acceptance:

- Save is disabled until a non-empty name is entered.
- Keyboard has Next/Done paths and dismisses while scrolling.
- The saved item survives relaunch.
- Sections refresh immediately after save.
- A same-day item appears under Today; an item within three days appears under Soon.

### 2. Add by photo/date scan

Home → Add → Scan date → Camera or Photo Library → OCR suggests a date → user confirms/adjusts → Save → Home reflects the item.

Acceptance:

- Permission denial produces actionable feedback.
- OCR never silently saves; the user confirms the detected date.
- Failure to detect a date leaves manual entry available.

### 3. Finish or discard food

Home → item → Ate it / Discarded → confirm → return Home → item disappears → completion feedback appears → History records the action.

Acceptance:

- Action is persisted.
- Home sections and Widget snapshot refresh immediately.
- The destructive discard action requires confirmation.

### 4. Edit or delete

Home → item → Edit → change values → Save → detail and Home show changes.  
Home → item → Delete → confirm → Home no longer shows the item.

Acceptance:

- Editing mutates the persisted model and refreshes all derived arrays.
- Delete is irreversible and confirmed.

### 5. Daily reminder

Settings → enable reminder → grant notification permission → choose time → a daily local notification is scheduled. Disabling removes it.

Acceptance:

- Denial is explained and the toggle returns to off.
- Changing time replaces the previous request.
- No notification is scheduled before explicit permission.

### 6. Explicit language selection

Settings → Language → Japanese / English / Simplified Chinese / System → UI updates immediately and choice survives relaunch.

Acceptance:

- Explicit choice always wins.
- System mode infers Japanese, Chinese, or English; unsupported languages fall back to English.

### 7. Privacy and support

Settings → Privacy Policy / Support → the corresponding trilingual GitHub Pages page opens only after the user taps it.

Acceptance:

- Settings does not expose URLs or the support email as row text.
- No web request occurs before a user opens a link.

## Visual principles

- Forced light appearance to guarantee review-device readability.
- Warm rice-paper background, deep ink text, subdued persimmon accent.
- Native typography and controls; generous spacing; no decorative clutter.
- Every pale surface uses explicit dark foreground and placeholder colors.
- Color is never the only urgency signal.

