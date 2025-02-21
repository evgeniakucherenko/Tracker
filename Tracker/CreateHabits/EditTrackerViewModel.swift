
import Foundation
import UIKit

final class EditTrackerViewModel {
    // MARK: - Properties
    private let originalTracker: Tracker
    private let categoryStore: TrackerCategoryStoreProtocol
    private let trackerStore: TrackerStoreProtocol

    var trackerModel: Tracker {
        return originalTracker
    }
    
    var categoryStoreRef: TrackerCategoryStoreProtocol {
        return categoryStore
    }
    
    var hasChanges: Bool {
        return name != originalTracker.name ||
               selectedColor != originalTracker.color ||
               selectedEmoji != originalTracker.emoji ||
               selectedSchedule != originalTracker.schedule ||
               selectedCategory != findCategory(for: originalTracker)?.title
    }
    
    private func findCategory(for tracker: Tracker) -> TrackerCategory? {
        return try? categoryStore.fetchAllCategories()
            .first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) })
    }

    // Свойства для редактирования
    var name: String
    var selectedCategory: String
    var selectedSchedule: Set<Weekday>
    var selectedColor: UIColor
    var selectedEmoji: String

    // MARK: - Initializer
    init(tracker: Tracker, categoryStore: TrackerCategoryStoreProtocol, trackerStore: TrackerStoreProtocol) {
        self.originalTracker = tracker
        self.categoryStore = categoryStore
        self.trackerStore = trackerStore
        
        self.name = tracker.name
        self.selectedSchedule = tracker.schedule
        self.selectedColor = tracker.color
        self.selectedEmoji = tracker.emoji
        
        // Находим категорию, к которой принадлежит трекер
        if let category = try? categoryStore.fetchAllCategories().first(where: {
            $0.trackers.contains(where: { $0.id == tracker.id })
        }) {
            self.selectedCategory = category.title
        } else {
            self.selectedCategory = "Категория по умолчанию"
        }
    }

    // MARK: - Save Changes
    func saveChanges() throws {
        let updatedTracker = Tracker(
            id: originalTracker.id,
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule,
            isPinned: originalTracker.isPinned
        )

        try trackerStore.updateTracker(updatedTracker)

        guard let oldCategory = try categoryStore.fetchAllCategories()
            .first(where: { $0.trackers.contains(where: { $0.id == originalTracker.id }) })
        else {
            throw NSError(domain: "EditTrackerViewModel", code: 404, userInfo: [NSLocalizedDescriptionKey: "Старая категория не найдена"])
        }

        try categoryStore.updateCategory(
            from: oldCategory,        
            to: selectedCategory,
            tracker: updatedTracker
        )

        print("Трекер успешно обновлён и перенесён в новую категорию!")
        NotificationCenter.default.post(name: .trackerUpdated, object: nil)
    }
}

