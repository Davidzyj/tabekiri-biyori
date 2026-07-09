import SwiftUI
import SwiftData

@main
struct TabekiriBiyoriApp: App {
    @State private var language = LanguageController()
    @State private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if purchases.hasCheckedEntitlements {
                    RootView()
                } else {
                    ZStack {
                        AppTheme.background.ignoresSafeArea()
                        ProgressView().tint(AppTheme.accent)
                    }
                }
            }
                .environment(language)
                .environment(purchases)
                .environment(\.locale, language.locale)
                .preferredColorScheme(.light)
                .tint(AppTheme.accent)
                .task { await purchases.prepare() }
        }
        .modelContainer(for: FoodItem.self)
    }
}
