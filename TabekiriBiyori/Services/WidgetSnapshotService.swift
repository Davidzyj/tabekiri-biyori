import Foundation
import WidgetKit

struct WidgetFood: Codable {
    let name: String
    let expiryDate: Date
}

enum WidgetSnapshotService {
    static let suite = "group.com.zhouyajie.tabekiribiyori"
    static let key = "widgetFoods"

    static func write(items: [FoodItem]) {
        let values = items
            .filter { $0.outcome == .active }
            .sorted { $0.expiryDate < $1.expiryDate }
            .prefix(3)
            .map { WidgetFood(name: $0.name, expiryDate: $0.expiryDate) }
        guard let data = try? JSONEncoder().encode(Array(values)) else { return }
        UserDefaults(suiteName: suite)?.set(data, forKey: key)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
