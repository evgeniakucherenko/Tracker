import UIKit

final class TrackerDataService: TrackerDataServiceProtocol {
    private let trackerStore: TrackerStoreProtocol
    private let categoryStore: TrackerCategoryStoreProtocol

    init(trackerStore: TrackerStoreProtocol, categoryStore: TrackerCategoryStoreProtocol) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
    }

    func loadCategories() async throws -> [TrackerCategory] {
        return try await categoryStore.fetchAllCategories()
    }

    // Загрузка выполненных трекеров для даты
    func loadCompletedTrackers(for date: Date) async throws -> Set<UUID> {
        let records = try await trackerStore.fetchAllTrackerRecords()
        let filteredRecords = records.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        return Set(filteredRecords.map { $0.id })
    }

    func addTracker(_ tracker: Tracker, to category: String) async throws {
        var allCategories = try await categoryStore.fetchAllCategories()
        
        if let index = allCategories.firstIndex(where: { $0.title == category }) {
            let oldCategory = allCategories[index]
            let updatedTrackers = oldCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(title: oldCategory.title, trackers: updatedTrackers)
            allCategories[index] = updatedCategory
            try await categoryStore.updateCategory(updatedCategory)
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            allCategories.append(newCategory)
            try await categoryStore.addCategory(newCategory)
        }
        
        try await trackerStore.addNewTracker(tracker)
    }

    func deleteTracker(_ tracker: Tracker) async throws {
        try await trackerStore.deleteTracker(tracker)
    }

    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) async throws {
        try await trackerStore.toggleTrackerCompletion(tracker, on: date)
    }

    func updateCategory(_ category: TrackerCategory) async throws {
        try await categoryStore.updateCategory(category)
    }

    func addCategory(_ category: TrackerCategory) async throws {
        try await categoryStore.addCategory(category)
    }

    func deleteCategory(_ category: TrackerCategory) async throws {
        try await categoryStore.deleteCategory(category)
    }

    func getCompletionCount(for tracker: Tracker) async throws -> Int {
        return try await trackerStore.getCompletionCount(for: tracker)
    }

    func addNewTracker(_ tracker: Tracker) async throws {
        try await trackerStore.addNewTracker(tracker)
    }
}
