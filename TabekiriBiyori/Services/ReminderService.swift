import Foundation
import UserNotifications

@MainActor
final class ReminderService {
    static let shared = ReminderService()
    private let center = UNUserNotificationCenter.current()
    private let identifier = "daily.food.expiry.summary"

    func setDailyReminder(enabled: Bool, hour: Int, minute: Int, title: String, body: String) async -> Bool {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        guard enabled else { return true }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else { return false }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            try await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
            return true
        } catch {
            return false
        }
    }
}

