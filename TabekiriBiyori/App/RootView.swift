import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("tab_home", systemImage: "leaf") }
            HistoryView()
                .tabItem { Label("tab_history", systemImage: "clock.arrow.circlepath") }
            SettingsView()
                .tabItem { Label("tab_settings", systemImage: "gearshape") }
        }
        .background(AppTheme.background)
        .foregroundStyle(AppTheme.ink)
    }
}

