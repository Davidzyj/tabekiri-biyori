import SwiftUI
import SwiftData

struct FoodDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let item: FoodItem
    let onFeedback: (String) -> Void
    @State private var showingEdit = false
    @State private var confirmDiscard = false
    @State private var confirmDelete = false

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    hero
                    detailCard
                    if item.outcome == .active { actionCard }
                    Button(role: .destructive) { confirmDelete = true } label: {
                        Text("delete_food").font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.accent).frame(maxWidth: .infinity).padding()
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if item.outcome == .active {
                Button("edit") { showingEdit = true }.foregroundStyle(AppTheme.accent)
            }
        }
        .sheet(isPresented: $showingEdit) { FoodEditorView(item: item) }
        .confirmationDialog("discard_confirm_title", isPresented: $confirmDiscard, titleVisibility: .visible) {
            Button("mark_discarded", role: .destructive) { complete(.discarded) }
            Button("cancel", role: .cancel) {}
        } message: { Text("discard_confirm_body") }
        .alert("delete_confirm_title", isPresented: $confirmDelete) {
            Button("cancel", role: .cancel) {}
            Button("delete", role: .destructive) {
                modelContext.delete(item)
                try? modelContext.save()
                onFeedback("feedback_deleted")
                dismiss()
            }
        } message: { Text("delete_confirm_body") }
    }

    private var hero: some View {
        Group {
            if let data = item.photoData, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
                    .frame(height: 220).frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.circle")
                        .font(.system(size: 64, weight: .light)).foregroundStyle(AppTheme.leaf)
                    Text(item.name).font(.title2.weight(.semibold)).foregroundStyle(AppTheme.ink)
                }
                .frame(height: 180).frame(maxWidth: .infinity)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24))
            }
        }
    }

    private var detailCard: some View {
        VStack(spacing: 0) {
            detailRow("expiry_date", value: item.expiryDate.formatted(date: .long, time: .omitted))
            Divider().overlay(AppTheme.divider)
            detailRow("expiry_kind", key: "expiry_\(item.expiryKind.rawValue)")
            Divider().overlay(AppTheme.divider)
            detailRow("storage_place", key: "storage_\(item.storage.rawValue)")
            if !item.note.isEmpty {
                Divider().overlay(AppTheme.divider)
                detailRow("note", value: item.note)
            }
        }
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppTheme.divider.opacity(0.5)))
    }

    private var actionCard: some View {
        HStack(spacing: 12) {
            Button { complete(.eaten) } label: {
                Label("mark_eaten", systemImage: "checkmark")
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(AppTheme.leaf, in: RoundedRectangle(cornerRadius: 15))
            }
            .accessibilityIdentifier("finishFoodButton")
            Button { confirmDiscard = true } label: {
                Label("mark_discarded", systemImage: "trash")
                    .foregroundStyle(AppTheme.accent).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 15))
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(AppTheme.accent))
            }
        }
    }

    private func detailRow(_ label: LocalizedStringKey, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).foregroundStyle(AppTheme.secondaryInk)
            Spacer()
            Text(value).foregroundStyle(AppTheme.ink).multilineTextAlignment(.trailing)
        }.padding(16)
    }

    private func detailRow(_ label: LocalizedStringKey, key: String) -> some View {
        HStack {
            Text(label).foregroundStyle(AppTheme.secondaryInk)
            Spacer()
            Text(LocalizedStringKey(key)).foregroundStyle(AppTheme.ink)
        }.padding(16)
    }

    private func complete(_ outcome: FoodOutcome) {
        item.outcome = outcome
        item.completedAt = .now
        item.updatedAt = .now
        try? modelContext.save()
        onFeedback(outcome == .eaten ? "feedback_eaten" : "feedback_discarded")
        dismiss()
    }
}
