import UIKit

final class TrackerDataService: TrackerDataServiceProtocol {
    private let trackerStore: TrackerStoreProtocol
    private let categoryStore: TrackerCategoryStoreProtocol

    init(trackerStore: TrackerStoreProtocol, categoryStore: TrackerCategoryStoreProtocol) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
    }

    func loadCategories() throws -> [TrackerCategory] {
        return try categoryStore.fetchAllCategories()
    }

    func loadCompletedTrackers(for date: Date) throws -> Set<UUID> {
        let records = try trackerStore.fetchAllTrackerRecords()
        let filteredRecords = records.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        return Set(filteredRecords.map { $0.id })
    }

    func addTracker(_ tracker: Tracker, to category: String) throws {
        // Пример добавления трекера в категорию:
        var allCategories = try categoryStore.fetchAllCategories()
        if let index = allCategories.firstIndex(where: { $0.title == category }) {
            let oldCategory = allCategories[index]
            let updatedTrackers = oldCategory.trackers + [tracker]
            let updatedCategory = TrackerCategory(title: oldCategory.title, trackers: updatedTrackers)
            allCategories[index] = updatedCategory
            try categoryStore.updateCategory(updatedCategory)
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            allCategories.append(newCategory)
            try categoryStore.addCategory(newCategory)
        }
        try trackerStore.addNewTracker(tracker)
    }

    func deleteTracker(_ tracker: Tracker) throws {
        try trackerStore.deleteTracker(tracker)
    }

    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) throws {
        try trackerStore.toggleTrackerCompletion(tracker, on: date)
    }

    func updateCategory(_ category: TrackerCategory) throws {
        try categoryStore.updateCategory(category)
    }

    func addCategory(_ category: TrackerCategory) throws {
        try categoryStore.addCategory(category)
    }

    func deleteCategory(_ category: TrackerCategory) throws {
        try categoryStore.deleteCategory(category)
    }

    func getCompletionCount(for tracker: Tracker) throws -> Int {
        return try trackerStore.getCompletionCount(for: tracker)
    }

    func addNewTracker(_ tracker: Tracker) throws {
        try trackerStore.addNewTracker(tracker)
    }
}

