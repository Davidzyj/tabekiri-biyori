import SwiftUI

struct ProUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LanguageController.self) private var language
    @Environment(PurchaseManager.self) private var purchases
    @State private var messageKey: String?

    let onUnlocked: (() -> Void)?

    init(onUnlocked: (() -> Void)? = nil) {
        self.onUnlocked = onUnlocked
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 22) {
                        hero
                        benefits
                        purchaseArea
                    }
                    .padding(20)
                }
            }
            .navigationTitle("pro_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("close") { dismiss() }
                        .foregroundStyle(AppTheme.secondaryInk)
                        .accessibilityIdentifier("closeProButton")
                }
            }
        }
        .preferredColorScheme(.light)
        .task { await purchases.prepare() }
    }

    private var hero: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(AppTheme.surface).frame(width: 112, height: 112)
                Image(systemName: purchases.isPro ? "checkmark.seal.fill" : "leaf.fill")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(purchases.isPro ? AppTheme.leaf : AppTheme.accent)
            }
            Text(purchases.isPro ? "pro_unlocked_title" : "pro_headline")
                .font(.title2.weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(.center)
            Text(purchases.isPro ? "pro_unlocked_body" : "pro_subheadline")
                .foregroundStyle(AppTheme.secondaryInk)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
    }

    private var benefits: some View {
        VStack(spacing: 0) {
            benefit("pro_benefit_unlimited", icon: "infinity")
            Divider().overlay(AppTheme.divider)
            benefit("pro_benefit_scan", icon: "viewfinder")
            Divider().overlay(AppTheme.divider)
            benefit("pro_benefit_reminder", icon: "bell")
            Divider().overlay(AppTheme.divider)
            benefit("pro_benefit_widget", icon: "rectangle.3.group")
        }
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppTheme.divider.opacity(0.55)))
    }

    @ViewBuilder
    private var purchaseArea: some View {
        if purchases.isPro {
            Button {
                dismiss()
                onUnlocked?()
            } label: {
                Text(onUnlocked == nil ? "done" : "pro_continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(AppTheme.leaf, in: RoundedRectangle(cornerRadius: 16))
            }
            .accessibilityIdentifier("proContinueButton")
        } else {
            VStack(spacing: 14) {
                Button {
                    Task { await purchase() }
                } label: {
                    Group {
                        if purchases.isProcessing {
                            ProgressView().tint(.white)
                        } else {
                            Text(purchaseButtonTitle)
                                .font(.headline)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 16))
                }
                .disabled(purchases.isProcessing || purchases.proProduct == nil)
                .opacity(purchases.proProduct == nil ? 0.72 : 1)
                .accessibilityIdentifier("purchaseProButton")

                if purchases.isLoadingProduct {
                    ProgressView().tint(AppTheme.accent)
                } else if purchases.productLoadFailed {
                    Button("pro_retry") {
                        Task { await purchases.loadProduct() }
                    }
                    .foregroundStyle(AppTheme.accent)
                }

                Button("restore_purchases") {
                    Task { await restore() }
                }
                .disabled(purchases.isProcessing)
                .foregroundStyle(AppTheme.ink)
                .accessibilityIdentifier("restorePurchasesButton")

                if let messageKey {
                    Text(LocalizedStringKey(messageKey))
                        .font(.caption)
                        .foregroundStyle(messageKey == "purchase_success" ? AppTheme.leaf : AppTheme.accent)
                        .multilineTextAlignment(.center)
                }

                Text("pro_one_time_note")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryInk)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func benefit(_ title: LocalizedStringKey, icon: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.leaf)
                .frame(width: 30)
            Text(title).foregroundStyle(AppTheme.ink)
            Spacer()
            Image(systemName: "checkmark").foregroundStyle(AppTheme.leaf)
        }
        .padding(16)
    }

    private var purchaseButtonTitle: String {
        guard let price = purchases.proProduct?.displayPrice else {
            return language.string("pro_loading")
        }
        return String(format: language.string("pro_buy_format"), price)
    }

    private func purchase() async {
        switch await purchases.purchasePro() {
        case .purchased:
            messageKey = "purchase_success"
        case .pending:
            messageKey = "purchase_pending"
        case .cancelled:
            messageKey = nil
        case .failed:
            messageKey = "purchase_failed"
        }
    }

    private func restore() async {
        switch await purchases.restorePurchases() {
        case .restored:
            messageKey = "restore_success"
        case .nothingToRestore:
            messageKey = "restore_nothing"
        case .failed:
            messageKey = "restore_failed"
        }
    }
}
