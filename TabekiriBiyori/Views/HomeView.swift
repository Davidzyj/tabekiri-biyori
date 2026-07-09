import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageController.self) private var language
    @Environment(PurchaseManager.self) private var purchases
    @Query(sort: \FoodItem.expiryDate) private var allItems: [FoodItem]
    @State private var showingAdd = false
    @State private var showingPro = false
    @State private var feedbackKey: String?
    @State private var didApplyUITestSetup = false

    private var activeItems: [FoodItem] { allItems.filter { $0.outcome == .active } }
    private var overdue: [FoodItem] { activeItems.filter { $0.daysRemaining < 0 } }
    private var today: [FoodItem] { activeItems.filter { $0.daysRemaining == 0 } }
    private var soon: [FoodItem] { activeItems.filter { (1...3).contains($0.daysRemaining) } }
    private var later: [FoodItem] { activeItems.filter { $0.daysRemaining > 3 } }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                if activeItems.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 22) {
                            headerCard
                            itemSection("section_overdue", items: overdue, tone: AppTheme.accent)
                            itemSection("section_today", items: today, tone: AppTheme.accent)
                            itemSection("section_soon", items: soon, tone: Color.orange)
                            itemSection("section_later", items: later, tone: AppTheme.leaf)
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("home_title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        beginAdding()
                    } label: {
                        Label("add_food", systemImage: "plus")
                    }
                    .foregroundStyle(AppTheme.accent)
                    .accessibilityIdentifier("addFoodButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                FoodEditorView { feedbackKey = "feedback_added" }
            }
            .sheet(isPresented: $showingPro) {
                ProUpgradeView {
                    Task {
                        try? await Task.sleep(for: .milliseconds(250))
                        showingAdd = true
                    }
                }
            }
            .overlay(alignment: .bottom) {
                if let feedbackKey {
                    Text(LocalizedStringKey(feedbackKey))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(AppTheme.ink, in: Capsule())
                        .padding(.bottom, 18)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .task {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation { self.feedbackKey = nil }
                        }
                }
            }
            .onChange(of: allItems.map(\.updatedAt)) { _, _ in WidgetSnapshotService.write(items: allItems) }
            .onAppear {
                applyUITestSetupIfNeeded()
                WidgetSnapshotService.write(items: allItems)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Spacer()
            ZStack {
                Circle().fill(AppTheme.surface).frame(width: 124, height: 124)
                Image(systemName: "carrot")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AppTheme.leaf)
            }
            Text("empty_title").font(.title2.weight(.semibold)).foregroundStyle(AppTheme.ink)
            Text("empty_body")
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.secondaryInk)
                .padding(.horizontal, 40)
            Button {
                beginAdding()
            } label: {
                Label("add_first", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(AppTheme.accent, in: Capsule())
            }
            .accessibilityIdentifier("addFirstFoodButton")
            Spacer()
        }
        .padding()
        .safeAreaPadding(.bottom, 76)
    }

    private var headerCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("home_summary").font(.caption.weight(.semibold)).foregroundStyle(AppTheme.secondaryInk)
                Text("\(activeItems.count)")
                    .font(.system(size: 38, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                Text("home_items_unit").font(.caption).foregroundStyle(AppTheme.secondaryInk)
                if !purchases.isPro {
                    Text(String(
                        format: language.string("free_usage_format"),
                        activeItems.count,
                        FeatureAccess.freeActiveItemLimit
                    ))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                }
            }
            Spacer()
            Image(systemName: "takeoutbag.and.cup.and.straw")
                .font(.system(size: 38, weight: .light))
                .foregroundStyle(AppTheme.leaf)
        }
        .padding(20)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppTheme.divider.opacity(0.5)))
    }

    @ViewBuilder
    private func itemSection(_ title: LocalizedStringKey, items: [FoodItem], tone: Color) -> some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Circle().fill(tone).frame(width: 8, height: 8)
                    Text(title).font(.headline).foregroundStyle(AppTheme.ink)
                    Text("\(items.count)").font(.caption).foregroundStyle(AppTheme.secondaryInk)
                }
                ForEach(items) { item in
                    NavigationLink {
                        FoodDetailView(item: item) { feedbackKey = $0 }
                    } label: {
                        FoodRow(item: item)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("foodRow_\(item.name)")
                }
            }
        }
    }

    private func beginAdding() {
        if FeatureAccess.canAddFood(activeItemCount: activeItems.count, isPro: purchases.isPro) {
            showingAdd = true
        } else {
            showingPro = true
        }
    }

    private func applyUITestSetupIfNeeded() {
#if DEBUG
        guard !didApplyUITestSetup,
              ProcessInfo.processInfo.arguments.contains("-uiTestingResetData") else { return }
        didApplyUITestSetup = true
        allItems.forEach(modelContext.delete)
        if ProcessInfo.processInfo.arguments.contains("-uiTestingSeedFreeLimit") {
            for index in 1...FeatureAccess.freeActiveItemLimit {
                modelContext.insert(FoodItem(
                    name: "Seed \(index)",
                    expiryDate: Calendar.current.date(byAdding: .day, value: index, to: .now) ?? .now,
                    expiryKind: .bestBefore,
                    storage: .fridge
                ))
            }
        }
        try? modelContext.save()
#endif
    }
}

struct FoodRow: View {
    let item: FoodItem

    var body: some View {
        HStack(spacing: 14) {
            if let data = item.photoData, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
                    .frame(width: 54, height: 54).clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Image(systemName: storageIcon)
                    .font(.title3)
                    .foregroundStyle(AppTheme.leaf)
                    .frame(width: 54, height: 54)
                    .background(AppTheme.background, in: RoundedRectangle(cornerRadius: 14))
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(item.name).font(.body.weight(.semibold)).foregroundStyle(AppTheme.ink).lineLimit(1)
                HStack(spacing: 6) {
                    Text(LocalizedStringKey("storage_\(item.storage.rawValue)"))
                    Text("•")
                    Text(item.expiryDate, format: .dateTime.month().day())
                }
                .font(.caption)
                .foregroundStyle(AppTheme.secondaryInk)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(dayLabel).font(.subheadline.weight(.bold)).foregroundStyle(dayColor)
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(AppTheme.secondaryInk)
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AppTheme.divider.opacity(0.45)))
    }

    private var storageIcon: String {
        switch item.storage {
        case .fridge: "refrigerator"
        case .freezer: "snowflake"
        case .pantry: "cabinet"
        }
    }
    private var dayLabel: LocalizedStringKey {
        if item.daysRemaining < 0 { return "day_overdue" }
        if item.daysRemaining == 0 { return "day_today" }
        return LocalizedStringKey("day_remaining \(item.daysRemaining)")
    }
    private var dayColor: Color { item.daysRemaining <= 0 ? AppTheme.accent : AppTheme.secondaryInk }
}
