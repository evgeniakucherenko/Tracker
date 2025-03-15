import Foundation

// Категории
protocol CategoryCreationDelegate: AnyObject {
    func didCreateCategory(_ categoryName: String)
}

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ categoryName: String)
}

// Трекеры
protocol CreateHabitsControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) async
}

// Протокол для передачи информации о созданном нерегулярном событии
protocol IrregularEventControllerDelegate: AnyObject {
    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) async
}

// Протокол для передачи информации о созданном трекере
protocol CreateTrackerControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) async
    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) async
}

protocol TrackersViewControllerDelegate: AnyObject {
    func showCreateTracker(delegate: CreateTrackerControllerDelegate)
    func showFilterScreen(delegate: TrackersFilteringCoordinatorDelegate)
    func didSelectFilter(at index: Int)
}

// Расписание
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelect(days: Set<Weekday>)
}

// Протокол для работы с хранилищем трекеров.
protocol TrackerStoreProtocol {
    func fetchAllTrackers() async throws -> [Tracker]
    func addNewTracker(_ tracker: Tracker) async throws
    func fetchTracker(by id: UUID) async throws -> Tracker?
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) async throws
    func getCompletionCount(for tracker: Tracker) async throws -> Int
    func fetchAllTrackerRecords() async throws -> [TrackerRecord]
    func subscribeToChanges(_ onChange: @escaping () -> Void)
    func updateTracker(_ tracker: Tracker) async throws
    func deleteTracker(_ tracker: Tracker) async throws
}

// Протокол для работы с хранилищем записей о выполненных трекерах.
protocol TrackerRecordStoreProtocol {
    func fetchAllTrackerRecords() throws -> [TrackerRecord]
    func addTrackerRecord(_ record: TrackerRecord) throws
}

// Протокол для работы с хранилищем категорий трекеров.
protocol TrackerCategoryStoreProtocol {
    func fetchAllCategories() async throws -> [TrackerCategory]
    func addCategory(_ category: TrackerCategory) async throws
    func deleteCategory(_ category: TrackerCategory) async throws
    func updateCategory(_ category: TrackerCategory) async throws
    func updateCategory(from oldCategory: TrackerCategory, to newCategoryTitle: String, tracker: Tracker?) async throws
    func subscribeToChanges(_ onChange: @escaping () -> Void)
    func fetchCategory(byTitle title: String) async throws -> TrackerCategory?
    func renameCategory(from oldCategory: TrackerCategory, to newCategoryTitle: String) async throws
    }

// Протокол для сервиса, управляющего закреплёнными трекерами.
protocol PinnedTrackersServiceProtocol {
    var pinnedTrackers: [Tracker] { get }
    func pinTracker(_ tracker: Tracker)
    func unpinTracker(_ tracker: Tracker)
}

// Протокол для сервиса, отвечающего за управление категориями (в памяти).
protocol CategoryManagementServiceProtocol {
    var categories: [TrackerCategory] { get set }
    var trackerToCategoryMap: [UUID: String] { get set }
    
    func removeTrackerFromItsCategory(_ tracker: Tracker)
    func addTrackerToOriginalCategory(_ tracker: Tracker)
}

// Протокол для сервиса фильтрации трекеров.
protocol TrackerFilteringServiceProtocol {
    func filteredCategories(
        categories: [TrackerCategory],
        pinnedTrackers: [Tracker],
        completedTrackers: Set<UUID>,
        currentDate: Date,
        weekdayMapping: [Int: Weekday],
        currentFilterIndex: Int
    ) -> [TrackerCategory]
}

// Протокол для сервиса, отвечающего за доступ к данным о трекерах и категориях.
protocol TrackerDataServiceProtocol {
    func loadCategories() async throws -> [TrackerCategory]
    func loadCompletedTrackers(for date: Date) async throws -> Set<UUID>
    func addTracker(_ tracker: Tracker, to category: String) async throws
    func deleteTracker(_ tracker: Tracker) async throws
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) async throws
    func updateCategory(_ category: TrackerCategory) async throws
    func addCategory(_ category: TrackerCategory) async throws
    func deleteCategory(_ category: TrackerCategory) async throws
    func getCompletionCount(for tracker: Tracker) async throws -> Int
    func addNewTracker(_ tracker: Tracker) async throws
}

// Протокол для сервиса, упрощающего работу с датами.
protocol DateServiceProtocol {
    func weekday(from date: Date, mapping: [Int: Weekday]) -> Weekday?
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool
    func isPastOrToday(_ date: Date) -> Bool
}
