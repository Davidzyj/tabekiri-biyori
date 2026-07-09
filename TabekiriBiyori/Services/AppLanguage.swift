import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system, japanese, english, simplifiedChinese
    var id: String { rawValue }

    var localeIdentifier: String? {
        switch self {
        case .system: nil
        case .japanese: "ja"
        case .english: "en"
        case .simplifiedChinese: "zh-Hans"
        }
    }
}

@MainActor
@Observable
final class LanguageController {
    var selection: AppLanguage {
        didSet { UserDefaults.standard.set(selection.rawValue, forKey: "appLanguage") }
    }

    init() {
        selection = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "") ?? .system
    }

    var locale: Locale {
        if let identifier = selection.localeIdentifier { return Locale(identifier: identifier) }
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        if code == "ja" { return Locale(identifier: "ja") }
        if code == "zh" { return Locale(identifier: "zh-Hans") }
        return Locale(identifier: "en")
    }

    func string(_ key: String) -> String {
        String(localized: String.LocalizationValue(key), locale: locale)
    }
}

