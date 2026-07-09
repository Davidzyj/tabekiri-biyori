import SwiftUI
import SwiftData

@main
struct TabekiriBiyoriApp: App {
    @State private var language = LanguageController()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(language)
                .environment(\.locale, language.locale)
                .preferredColorScheme(.light)
                .tint(AppTheme.accent)
        }
        .modelContainer(for: FoodItem.self)
    }
}

