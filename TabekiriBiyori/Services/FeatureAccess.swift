enum FeatureAccess {
    static let freeActiveItemLimit = 10

    static func canAddFood(activeItemCount: Int, isPro: Bool) -> Bool {
        isPro || activeItemCount < freeActiveItemLimit
    }

    static func canUsePremiumFeatures(isPro: Bool) -> Bool {
        isPro
    }
}

