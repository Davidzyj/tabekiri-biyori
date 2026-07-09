import WidgetKit
import SwiftUI

struct FoodEntry: TimelineEntry {
    let date: Date
    let foods: [WidgetFood]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> FoodEntry {
        FoodEntry(date: .now, foods: [WidgetFood(name: "豆腐", expiryDate: .now)])
    }

    func getSnapshot(in context: Context, completion: @escaping (FoodEntry) -> Void) {
        completion(FoodEntry(date: .now, foods: load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FoodEntry>) -> Void) {
        let entry = FoodEntry(date: .now, foods: load())
        completion(Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .hour, value: 1, to: .now)!)))
    }

    private func load() -> [WidgetFood] {
        guard let data = UserDefaults(suiteName: WidgetSnapshotService.suite)?.data(forKey: WidgetSnapshotService.key),
              let foods = try? JSONDecoder().decode([WidgetFood].self, from: data) else { return [] }
        return foods
    }
}

struct TabekiriWidgetView: View {
    let entry: FoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(String(localized: "widget_title", table: "Widget"), systemImage: "leaf")
                .font(.headline).foregroundStyle(AppTheme.leaf)
            if entry.foods.isEmpty {
                Spacer()
                Text(String(localized: "widget_empty", table: "Widget")).font(.caption).foregroundStyle(AppTheme.secondaryInk)
                Spacer()
            } else {
                ForEach(Array(entry.foods.enumerated()), id: \.offset) { _, food in
                    HStack {
                        Text(food.name).lineLimit(1).foregroundStyle(AppTheme.ink)
                        Spacer()
                        Text(food.expiryDate, format: .dateTime.month().day())
                            .font(.caption.weight(.semibold)).foregroundStyle(AppTheme.secondaryInk)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .containerBackground(AppTheme.background, for: .widget)
    }
}

@main
struct TabekiriWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TabekiriWidget", provider: Provider()) { entry in
            TabekiriWidgetView(entry: entry)
                .environment(\.locale, Locale.current)
        }
        .configurationDisplayName(LocalizedStringResource("widget_display_name", table: "Widget"))
        .description(LocalizedStringResource("widget_description", table: "Widget"))
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
