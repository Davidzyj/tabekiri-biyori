import SwiftUI

struct SettingsView: View {
    @Environment(LanguageController.self) private var language
    @AppStorage("dailyReminderEnabled") private var reminderEnabled = false
    @AppStorage("dailyReminderHour") private var reminderHour = 20
    @AppStorage("dailyReminderMinute") private var reminderMinute = 0
    @State private var permissionAlert = false

    private var reminderTime: Binding<Date> {
        Binding {
            Calendar.current.date(from: DateComponents(hour: reminderHour, minute: reminderMinute)) ?? .now
        } set: { newDate in
            let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
            reminderHour = components.hour ?? 20
            reminderMinute = components.minute ?? 0
            Task { await reschedule(enabled: reminderEnabled) }
        }
    }

    var body: some View {
        @Bindable var language = language
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                Form {
                    Section("settings_reminder_section") {
                        Toggle("daily_reminder", isOn: Binding(
                            get: { reminderEnabled },
                            set: { newValue in Task { await reschedule(enabled: newValue) } }
                        ))
                        .tint(AppTheme.leaf)
                        if reminderEnabled {
                            DatePicker("reminder_time", selection: reminderTime, displayedComponents: .hourAndMinute)
                        }
                        Text("reminder_description")
                            .font(.caption).foregroundStyle(AppTheme.secondaryInk)
                    }
                    .listRowBackground(AppTheme.surface)

                    Section("settings_language_section") {
                        Picker("language", selection: $language.selection) {
                            Text("language_system").tag(AppLanguage.system)
                            Text("language_japanese").tag(AppLanguage.japanese)
                            Text("language_english").tag(AppLanguage.english)
                            Text("language_chinese").tag(AppLanguage.simplifiedChinese)
                        }
                    }
                    .listRowBackground(AppTheme.surface)

                    Section("settings_help_section") {
                        Link(destination: URL(string: "https://davidzyj.github.io/tabekiri-biyori/privacy/")!) {
                            settingsRow("privacy_policy", icon: "hand.raised")
                        }
                        Link(destination: URL(string: "https://davidzyj.github.io/tabekiri-biyori/support/")!) {
                            settingsRow("support", icon: "questionmark.circle")
                        }
                    }
                    .listRowBackground(AppTheme.surface)

                    Section("settings_about_section") {
                        HStack {
                            Text("version").foregroundStyle(AppTheme.ink)
                            Spacer()
                            Text("1.0.0").foregroundStyle(AppTheme.secondaryInk)
                        }
                        HStack {
                            Text("local_only").foregroundStyle(AppTheme.ink)
                            Spacer()
                            Image(systemName: "checkmark.shield.fill").foregroundStyle(AppTheme.leaf)
                        }
                    }
                    .listRowBackground(AppTheme.surface)
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(AppTheme.ink)
            }
            .navigationTitle("settings_title")
            .alert("notification_denied_title", isPresented: $permissionAlert) {
                Button("ok", role: .cancel) {}
            } message: { Text("notification_denied_body") }
        }
    }

    private func settingsRow(_ title: LocalizedStringKey, icon: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(AppTheme.leaf).frame(width: 28)
            Text(title).foregroundStyle(AppTheme.ink)
            Spacer()
            Image(systemName: "arrow.up.right").font(.caption).foregroundStyle(AppTheme.secondaryInk)
        }
    }

    private func reschedule(enabled: Bool) async {
        let success = await ReminderService.shared.setDailyReminder(
            enabled: enabled,
            hour: reminderHour,
            minute: reminderMinute,
            title: language.string("notification_title"),
            body: language.string("notification_body")
        )
        reminderEnabled = enabled && success
        if enabled && !success { permissionAlert = true }
    }
}

