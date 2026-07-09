# App Store Connect Template

## App record

- Version: 1.0.0
- Bundle ID: `com.zhouyajie.tabekiribiyori`
- SKU suggestion: `tabekiri-biyori-ios-001`
- Primary language: Japanese
- Primary category: Lifestyle
- Secondary category: Utilities
- Price: Free
- Monetization: one non-consumable In-App Purchase
- Support email: `jay212315@gmail.com`
- Privacy URL: `https://davidzyj.github.io/tabekiri-biyori/privacy/`
- Support URL: `https://davidzyj.github.io/tabekiri-biyori/support/`
- Marketing URL: leave blank
- Copyright: owner must enter the correct year/name

## Japanese

- Name: たべきり日和
- Subtitle: 食品の期限を、やさしく管理
- Promotional text: 冷蔵・冷凍・常温の食品を、期限が近い順にすっきり確認。Proでは写真からの日付読み取りにも対応します。
- Keywords: 賞味期限,消費期限,冷蔵庫,食品ロス,食材,在庫,冷凍,リマインダー
- Description:

たべきり日和は、食品の期限だけを静かに見守る、シンプルな記録アプリです。

食品名と期限を登録すると、「今日まで」「3日以内」「そのあと」に分けて表示。次に食べたいものが、ひと目でわかります。

主な機能
・消費期限と賞味期限を分けて記録
・冷蔵、冷凍、常温の保存場所
・食べきり／廃棄の履歴

無料版では、食品を10品まで手動で登録できます。

Pro永久版（買い切り）
・食品を無制限に登録
・写真から印字された日付を端末内で読み取り
・1日1回のやさしいリマインダー
・期限が近い食品を表示するウィジェット

アカウント登録は不要です。食品、写真、設定は端末内に保存され、広告やトラッキングもありません。

## English

- Name: Freshly
- Subtitle: A calmer food expiry list
- Promotional text: See what to enjoy next across your fridge, freezer, and pantry. Pro adds private, on-device date scanning.
- Keywords: expiry,food,fridge,pantry,freezer,waste,reminder,freshness
- Description:

Freshly is a quiet, focused way to keep an eye on food dates.

Add a food and its date, then see it grouped into Today, Within 3 Days, or Later. The next thing to enjoy is always clear.

Features:
• Separate Use By and Best Before dates
• Fridge, freezer, and pantry locations
• Finished and discarded history

The free plan supports manual entry for up to 10 active foods.

Pro Lifetime (one-time purchase):
• Unlimited active foods
• On-device printed-date recognition from photos
• One gentle daily reminder
• A widget for the three nearest dates

No account is required. Food, photos, and settings remain on your device. There are no ads or tracking.

## Simplified Chinese

- Name: 食鲜日记
- Subtitle: 简洁好用的食品期限记录
- Promotional text: 清楚查看冷藏、冷冻和常温食品的期限；Pro 还支持在本机从照片识别日期。
- Keywords: 保质期,食品,冰箱,食材,临期,冷藏,冷冻,提醒
- Description:

食鲜日记是一款安静、专注的食品期限记录工具。

添加食品及期限后，应用会按“今天到期”“3天以内”和“以后”进行整理，让你一眼看到接下来该吃什么。

主要功能：
• 分别记录食用期限与赏味期限
• 冷藏、冷冻与常温三种位置
• 吃完与丢弃记录

免费版可以手动记录最多10项有效食品。

Pro 永久版（一次购买）：
• 无限添加有效食品
• 在本机从照片识别印刷日期
• 每天一次温和提醒
• 显示最近三项食品的小组件

无需注册账号。食品、照片和设置均保存在设备本地，不含广告或跟踪。

## App Privacy

- Data collected: None
- Tracking: No
- Analytics: None
- Advertising: None
- Account: None
- Third-party SDKs: None
- Purchase data received by developer: None; StoreKit processes purchases through Apple.
- Rationale: all food records, optional photos, reminder settings, and language settings remain on device. The app reads signed StoreKit entitlement status but has no backend and stores no payment details.

## Review information

- Demo account: Not required.
- Contact name/phone: owner must fill.
- Review notes:

The app does not require an account. The free plan allows up to 10 active foods with manual entry. Tap the plus button, enter a food name, select a date, and save. Open an item to edit it or mark it finished/discarded.

The app offers one non-consumable lifetime IAP. Open Settings → Pro to purchase or restore. Pro unlocks unlimited active foods, on-device Vision date recognition, a daily local reminder, and Widget content. The displayed price comes from StoreKit. Existing foods remain accessible if Pro is not active. Notification permission is requested only after a Pro user enables Daily Reminder.

## Compliance and age rating

- Export compliance: app does not use non-exempt encryption; `ITSAppUsesNonExemptEncryption` is false.
- Content: no violence, sexual content, gambling, medical treatment, unrestricted web access, or user-generated content.
- Suggested age rating: 4+ / lowest available result, subject to the current questionnaire.
- In-app purchases: One non-consumable lifetime unlock.
- Subscriptions: None.

## In-App Purchase

- Reference name: `Tabekiri Biyori Pro Lifetime`
- Product ID: `com.zhouyajie.tabekiribiyori.pro.lifetime`
- Type: Non-Consumable
- Family Sharing: Off for version 1.0.0
- Suggested Japanese price: ¥800; owner selects the production price in App Store Connect

### Japanese localization

- Display name: たべきり日和 Pro 永久版
- Description: 一度の購入で、食品数の上限解除、期限読み取り、通知、ウィジェットを永久に利用できます。

### English localization

- Display name: Freshly Pro Lifetime
- Description: One-time purchase to unlock unlimited food, date scanning, reminders, and widgets.

### Simplified Chinese localization

- Display name: 食鲜日记 Pro 永久版
- Description: 一次购买，永久解锁无限食品、日期识别、提醒和小组件。

### Owner-only IAP setup

1. Accept the Paid Apps Agreement and complete tax/banking information.
2. Create a Non-Consumable product with the exact product ID above.
3. Add Japanese, English, and Simplified Chinese metadata.
4. Choose the production price and add the required IAP review screenshot later.
5. Attach the IAP to version 1.0.0 and submit it with the first app version.

## Assets

- App icon: `TabekiriBiyori/Assets.xcassets/AppIcon.appiconset/AppIcon.png`
- Icon validation: 1024×1024, RGB, no alpha.
- Screenshots: intentionally not prepared in this phase.
