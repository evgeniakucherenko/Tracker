import UIKit

final class TrackersViewModel {
    // MARK: - Properties
    var categoryStore: TrackerCategoryStoreProtocol
    private let pinnedTrackersService: PinnedTrackersServiceProtocol
    private var categoryManagementService: CategoryManagementServiceProtocol
    private let filteringService: TrackerFilteringServiceProtocol
    private let dateService: DateServiceProtocol
    private let trackerDataService: TrackerDataServiceProtocol
    private var trackerStore: TrackerStoreProtocol
 
    private(set) var completedTrackers: Set<UUID> = []
    private(set) var filteredCategories: [TrackerCategory] = []
    private var currentFilterIndex: Int = 0
    
    private var currentDate: Date = Date() {
        didSet {
            onDateChanged?(currentDate)
            loadCompletedTrackers()
            loadFilteredCategories()
            onDataUpdated?()
        }
    }
    
    var categories: [TrackerCategory] {
        get { categoryManagementService.categories }
        set { categoryManagementService.categories = newValue }
    }

    var trackerToCategoryMap: [UUID: String] {
        get { categoryManagementService.trackerToCategoryMap }
        set { categoryManagementService.trackerToCategoryMap = newValue }
    }
    
    var trackerStoreRef: TrackerStoreProtocol {
        return trackerStore
    }

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    var onDateChanged: ((Date) -> Void)?
    
    private let weekdayMapping: [Int: Weekday] = [
        1: .sunday, 2: .monday, 3: .tuesday, 4: .wednesday,
        5: .thursday, 6: .friday, 7: .saturday
    ]
    
    // MARK: - Initializer
    init(
        trackerStore: TrackerStoreProtocol,
        categoryStore: TrackerCategoryStoreProtocol,
        pinnedTrackersService: PinnedTrackersServiceProtocol = PinnedTrackersService(),
        categoryManagementService: CategoryManagementServiceProtocol = CategoryManagementService(),
        filteringService: TrackerFilteringServiceProtocol = TrackerFilteringService(),
        dateService: DateServiceProtocol = DateService(),
        trackerDataService: TrackerDataServiceProtocol? = nil
    ) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.pinnedTrackersService = pinnedTrackersService
        self.categoryManagementService = categoryManagementService
        self.filteringService = filteringService
        self.dateService = dateService
        self.trackerDataService = trackerDataService ?? TrackerDataService(trackerStore: trackerStore, categoryStore: categoryStore)
    }
    
    // MARK: - Data Loading Methods
    func loadInitialData() {
        loadCategories()
        loadCompletedTrackers()
        loadFilteredCategories()
        onDataUpdated?()
    }
    
    private func loadCategories() {
        do {
            let fetchedCategories = try trackerDataService.loadCategories()
            self.categories = fetchedCategories
            self.trackerToCategoryMap = fetchedCategories.reduce(into: [:]) { result, category in
                for tracker in category.trackers {
                    result[tracker.id] = category.title
                }
            }
        } catch {
            onError?("Ошибка при загрузке категорий: \(error.localizedDescription)")
        }
    }
    
    private func loadCompletedTrackers() {
        do {
            let completedSet = try trackerDataService.loadCompletedTrackers(for: currentDate)
            completedTrackers = completedSet
        } catch {
            onError?("Ошибка при загрузке выполненных трекеров: \(error.localizedDescription)")
        }
    }
    
    private func loadFilteredCategories() {
        updateFilteredCategories()
    }
    
    private func updateFilteredCategories() {
        filteredCategories = filteringService.filteredCategories(
            categories: categories,
            pinnedTrackers: pinnedTrackersService.pinnedTrackers,
            completedTrackers: completedTrackers,
            currentDate: currentDate,
            weekdayMapping: weekdayMapping,
            currentFilterIndex: currentFilterIndex
        )
    }
    
    // MARK: - Public Methods
    func updateDate(_ date: Date) {
        currentDate = date
    }
    
    func applyFilter(at index: Int) {
        currentFilterIndex = index
        updateFilteredCategories()
        onDataUpdated?()
    }
    
    // MARK: - Tracker Management
    func addTracker(_ tracker: Tracker, to category: String) {
        do {
            try trackerDataService.addTracker(tracker, to: category)
            loadCategories()
            loadFilteredCategories()
            onDataUpdated?()
        } catch {
            onError?("Ошибка при добавлении трекера: \(error.localizedDescription)")
        }
    }

    func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerDataService.deleteTracker(tracker)

            if let categoryIndex = categories.firstIndex(where: { $0.trackers.contains(where: { $0.id == tracker.id }) }) {
                let category = categories[categoryIndex]
                let updatedTrackers = category.trackers.filter { $0.id != tracker.id }

                if updatedTrackers.isEmpty {
                    categories.remove(at: categoryIndex)
                    try trackerDataService.deleteCategory(category)
                } else {
                    let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
                    categories[categoryIndex] = updatedCategory
                    try trackerDataService.updateCategory(updatedCategory)
                }
            }

            pinnedTrackersService.unpinTracker(tracker)
            trackerToCategoryMap.removeValue(forKey: tracker.id)

            loadFilteredCategories()
            onDataUpdated?()
        } catch {
            onError?("Ошибка при удалении трекера: \(error.localizedDescription)")
        }
    }
    
    func toggleTrackerCompletion(_ tracker: Tracker) {
        guard dateService.isPastOrToday(currentDate) else { return }
        do {
            try trackerDataService.toggleTrackerCompletion(tracker, on: currentDate)
            loadCompletedTrackers()
            loadFilteredCategories()
            onDataUpdated?()
        } catch {
            onError?("Ошибка при изменении статуса трекера: \(error.localizedDescription)")
        }
    }
    
    func getCompletionCount(for tracker: Tracker) -> Int {
        do {
            return try trackerDataService.getCompletionCount(for: tracker)
        } catch {
            onError?("Ошибка при получении количества выполнений: \(error.localizedDescription)")
            return 0
        }
    }

    func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        return completedTrackers.contains(tracker.id)
    }

    // MARK: - Pinning Methods
    func pinTracker(_ tracker: Tracker) {
        categoryManagementService.removeTrackerFromItsCategory(tracker)
        pinnedTrackersService.pinTracker(tracker)
        loadFilteredCategories()
        onDataUpdated?()
    }

    func unpinTracker(_ tracker: Tracker) {
        pinnedTrackersService.unpinTracker(tracker)
        categoryManagementService.addTrackerToOriginalCategory(tracker)
        loadFilteredCategories()
        onDataUpdated?()
    }
    
    // MARK: - Table View Data Source Helpers
    func getTracker(at indexPath: IndexPath) -> Tracker? {
        guard indexPath.section < filteredCategories.count,
              indexPath.row < filteredCategories[indexPath.section].trackers.count else {
            return nil
        }
        return filteredCategories[indexPath.section].trackers[indexPath.row]
    }

    func numberOfSections() -> Int {
        return filteredCategories.count
    }

    func numberOfItems(in section: Int) -> Int {
        guard section < filteredCategories.count else { return 0 }
        return filteredCategories[section].trackers.count
    }

    func titleForSection(_ section: Int) -> String? {
        guard section < filteredCategories.count else { return nil }
        return filteredCategories[section].title
    }
}

extension TrackersViewModel {
    func filterTrackers(with query: String) {
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { $0.name.lowercased().contains(query) }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        onDataUpdated?()
    }

    func clearSearch() {
        loadFilteredCategories()
        onDataUpdated?()
    }
}
