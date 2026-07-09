import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \FoodItem.completedAt, order: .reverse) private var allItems: [FoodItem]
    private var history: [FoodItem] { allItems.filter { $0.outcome != .active } }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                if history.isEmpty {
                    ContentUnavailableView {
                        Label("history_empty_title", systemImage: "clock")
                            .foregroundStyle(AppTheme.ink)
                    } description: {
                        Text("history_empty_body").foregroundStyle(AppTheme.secondaryInk)
                    }
                } else {
                    List {
                        ForEach(history) { item in
                            NavigationLink { FoodDetailView(item: item) { _ in } } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: item.outcome == .eaten ? "checkmark.circle.fill" : "trash.circle.fill")
                                        .foregroundStyle(item.outcome == .eaten ? AppTheme.leaf : AppTheme.accent)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name).foregroundStyle(AppTheme.ink)
                                        Text(item.completedAt ?? item.updatedAt, format: .dateTime.year().month().day())
                                            .font(.caption).foregroundStyle(AppTheme.secondaryInk)
                                    }
                                    Spacer()
                                    Text(LocalizedStringKey(item.outcome == .eaten ? "status_eaten" : "status_discarded"))
                                        .font(.caption.weight(.semibold)).foregroundStyle(AppTheme.secondaryInk)
                                }
                            }
                            .listRowBackground(AppTheme.surface)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("history_title")
        }
    }
}

