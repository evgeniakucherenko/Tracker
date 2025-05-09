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
            Task {
                await loadCompletedTrackers()
                await loadFilteredCategories()
                onDataUpdated?()
            }
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

    var onDateChanged: ((Date) -> Void)?
    
    var coordinator: TrackersCoordinator?
    
    lazy var onError: ((String) -> Void)? = { [weak self] in
        self?.coordinator?.showAlert(title: "Ошибка", message: $0)
    }
    
    lazy var onDataUpdated: (() -> Void)? = { [weak self] in
        self?.coordinator?.reloadTrackersScreen()
    }
    
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTrackerUpdatedNotification),
            name: .trackerUpdated,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .trackerUpdated, object: nil)
    }
    
    @objc private func onTrackerUpdatedNotification(_ notification: Notification) {
        Task {
            await loadInitialData()
            onDataUpdated?()
        }
    }
    
    // MARK: - Data Loading Methods
    func loadInitialData() async {
        await loadCategories()
        await loadCompletedTrackers()
        await loadFilteredCategories()
        onDataUpdated?()
    }
    
    private func loadCategories() async {
        do {
            let fetchedCategories = try await trackerDataService.loadCategories()
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
    
    private func loadCompletedTrackers() async {
        do {
            let completedSet = try await trackerDataService.loadCompletedTrackers(for: currentDate)
            completedTrackers = completedSet
        } catch {
            onError?("Ошибка при загрузке выполненных трекеров: \(error.localizedDescription)")
        }
    }
    
    private func loadFilteredCategories() async {
        updateFilteredCategories()
    }
    
    private func updateFilteredCategories() {
        let newFiltered = filteringService.filteredCategories(
            categories: categories,
            pinnedTrackers: pinnedTrackersService.pinnedTrackers,
            completedTrackers: completedTrackers,
            currentDate: currentDate,
            weekdayMapping: weekdayMapping,
            currentFilterIndex: currentFilterIndex
        )

        filteredCategories = newFiltered
        onDataUpdated?()
    }
    
    // MARK: - Public Methods
    func updateDate(_ date: Date) {
        print("🟢 Дата изменилась: \(date)")
        currentDate = date
    }
    
    func applyFilter(at index: Int) {
        currentFilterIndex = index
        updateFilteredCategories()
        onDataUpdated?()
    }
    
    // MARK: - Tracker Management
    func addTracker(_ tracker: Tracker, to category: String) async {
        do {
            try await trackerDataService.addTracker(tracker, to: category)
            await loadCategories()
            await loadFilteredCategories()
            print("✅ TrackersViewModel: onDataUpdated вызван")
            onDataUpdated?()
        } catch {
             onError?("Ошибка при добавлении трекера: \(error.localizedDescription)")
        }
    }

    func deleteTracker(_ tracker: Tracker) async {
        do {
            try await trackerDataService.deleteTracker(tracker)
            await loadCategories()
            await loadFilteredCategories()
            onDataUpdated?()
        } catch {
            onError?("Ошибка при удалении трекера: \(error.localizedDescription)")
        }
    }
    
    func toggleTrackerCompletion(_ tracker: Tracker) async {
        guard dateService.isPastOrToday(currentDate) else { return }
        do {
            try await trackerDataService.toggleTrackerCompletion(tracker, on: currentDate)
            await loadCompletedTrackers()
            await loadFilteredCategories()
            onDataUpdated?()
        } catch {
            onError?("Ошибка при изменении статуса трекера: \(error.localizedDescription)")
        }
    }
    
    func getCompletionCount(for tracker: Tracker) async -> Int {
        do {
            return try await trackerDataService.getCompletionCount(for: tracker)
        } catch {
            onError?("Ошибка при получении количества выполнений: \(error.localizedDescription)")
            return 0
        }
    }

    func isTrackerCompleted(_ tracker: Tracker) -> Bool {
        return completedTrackers.contains(tracker.id)
    }
    
    func getTracker(at indexPath: IndexPath) -> Tracker? {
           guard indexPath.section < filteredCategories.count,
                 indexPath.row < filteredCategories[indexPath.section].trackers.count else {
               return nil
           }
           return filteredCategories[indexPath.section].trackers[indexPath.row]
       }

    // MARK: - Pinning Methods
    func pinTracker(_ tracker: Tracker) {
        categoryManagementService.removeTrackerFromItsCategory(tracker)
        pinnedTrackersService.pinTracker(tracker)
        updateFilteredCategories()
        onDataUpdated?()
    }

    func unpinTracker(_ tracker: Tracker) {
        pinnedTrackersService.unpinTracker(tracker)
        categoryManagementService.addTrackerToOriginalCategory(tracker)
        updateFilteredCategories()
        onDataUpdated?()
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
    func filterTrackers(with query: String) async {
        filteredCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { $0.name.lowercased().contains(query) }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        onDataUpdated?()
    }

    func clearSearch() async {
        await loadFilteredCategories()
        onDataUpdated?()
    }
}
