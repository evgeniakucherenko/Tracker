import UIKit

final class CategoryManagementService: CategoryManagementServiceProtocol {
    var categories: [TrackerCategory]
    var trackerToCategoryMap: [UUID: String]
    
    init(categories: [TrackerCategory] = [], trackerToCategoryMap: [UUID: String] = [:]) {
        self.categories = categories
        self.trackerToCategoryMap = trackerToCategoryMap
    }
    
    func removeTrackerFromItsCategory(_ tracker: Tracker) {
        guard let categoryIndex = categories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) else {
            print("Error: Категория для трекера не найдена при попытке удалить трекер из категории")
            return
        }
        
        let category = categories[categoryIndex]
        let updatedTrackers = category.trackers.filter { $0.id != tracker.id }
        let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
        categories[categoryIndex] = updatedCategory
    }
    
    func addTrackerToOriginalCategory(_ tracker: Tracker) {
        guard let originalCategoryTitle = trackerToCategoryMap[tracker.id],
              let categoryIndex = categories.firstIndex(where: { $0.title == originalCategoryTitle }) else {
            print("Оригинальная категория для трекера не найдена при попытке добавить трекер в категорию")
            return
        }

        var updatedTracker = tracker
        updatedTracker.isPinned = false
        
        let category = categories[categoryIndex]
        let updatedTrackers = category.trackers + [updatedTracker]
        let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
        categories[categoryIndex] = updatedCategory
    }
}
