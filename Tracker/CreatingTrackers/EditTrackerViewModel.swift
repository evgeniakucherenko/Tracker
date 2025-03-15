
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
        get async {
            let categoryTitle = await findCategory(for: originalTracker)?.title ?? "Категория по умолчанию"
            return name != originalTracker.name ||
                selectedColor != originalTracker.color ||
                selectedEmoji != originalTracker.emoji ||
                selectedSchedule != originalTracker.schedule ||
                selectedCategory != categoryTitle
        }
    }
    
    private func findCategory(for tracker: Tracker) async -> TrackerCategory? {
        do {
            let categories = try await categoryStore.fetchAllCategories()
            return categories.first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) })
        } catch {
            print("Ошибка при получении категорий: \(error.localizedDescription)")
            return nil
        }
    }

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
        
        self.selectedCategory = "Категория по умолчанию"
        
        Task { [weak self] in
            guard let self = self else { return }
            do {
                if let category = try await categoryStore.fetchAllCategories()
                    .first(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
                    self.selectedCategory = category.title
                }
            } catch {
                print("Ошибка при загрузке категорий: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Save Changes
    func saveChanges() async throws {
        let updatedTracker = Tracker(
            id: originalTracker.id,
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule,
            isPinned: originalTracker.isPinned
        )

        do {
            try await trackerStore.updateTracker(updatedTracker)

            guard let oldCategory = try await categoryStore.fetchAllCategories()
                    .first(where: { $0.trackers.contains(where: { $0.id == originalTracker.id }) })
            else {
                throw NSError(
                    domain: "EditTrackerViewModel",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Старая категория не найдена"]
                )
            }

            try await categoryStore.updateCategory(
                from: oldCategory,
                to: selectedCategory,
                tracker: updatedTracker
            )

            print("Трекер успешно обновлён и перенесён в новую категорию!")
            NotificationCenter.default.post(name: .trackerUpdated, object: nil)

        } catch {
            print("Ошибка при сохранении изменений: \(error.localizedDescription)")
            throw error
        }
    }
}

