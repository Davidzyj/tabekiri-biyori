import Foundation
import SwiftData

enum ExpiryKind: String, Codable, CaseIterable, Identifiable {
    case useBy, bestBefore
    var id: String { rawValue }
}

enum StoragePlace: String, Codable, CaseIterable, Identifiable {
    case fridge, freezer, pantry
    var id: String { rawValue }
}

enum FoodOutcome: String, Codable {
    case active, eaten, discarded
}

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var expiryDate: Date
    var expiryKindRaw: String
    var storageRaw: String
    var note: String
    var createdAt: Date
    var updatedAt: Date
    var outcomeRaw: String
    var completedAt: Date?
    @Attribute(.externalStorage) var photoData: Data?

    init(
        name: String,
        expiryDate: Date,
        expiryKind: ExpiryKind,
        storage: StoragePlace,
        note: String = "",
        photoData: Data? = nil
    ) {
        id = UUID()
        self.name = name
        self.expiryDate = Calendar.current.startOfDay(for: expiryDate)
        expiryKindRaw = expiryKind.rawValue
        storageRaw = storage.rawValue
        self.note = note
        createdAt = .now
        updatedAt = .now
        outcomeRaw = FoodOutcome.active.rawValue
        self.photoData = photoData
    }

    var expiryKind: ExpiryKind {
        get { ExpiryKind(rawValue: expiryKindRaw) ?? .bestBefore }
        set { expiryKindRaw = newValue.rawValue }
    }

    var storage: StoragePlace {
        get { StoragePlace(rawValue: storageRaw) ?? .fridge }
        set { storageRaw = newValue.rawValue }
    }

    var outcome: FoodOutcome {
        get { FoodOutcome(rawValue: outcomeRaw) ?? .active }
        set { outcomeRaw = newValue.rawValue }
    }

    var daysRemaining: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: .now),
            to: Calendar.current.startOfDay(for: expiryDate)
        ).day ?? 0
    }
}

