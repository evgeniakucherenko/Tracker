import UIKit
import CoreData

final class TrackerCategoryStore: CoreDataStore,TrackerCategoryStoreProtocol {

    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<NSManagedObject>?
    private var onChangeCallback: (() -> Void)?
    private let entityName = "TrackerCategoryCoreData"

    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    // MARK: - Public Methods
    func fetchAllCategories() throws -> [TrackerCategory] {
        guard let fetchedCategories = fetchedResultsController?.fetchedObjects else {
            throw NSError(domain: "FetchError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки категорий"])
        }
        return fetchedCategories.compactMap { convertToTrackerCategory(from: $0) }
    }

    func fetchCategory(byTitle title: String) throws -> TrackerCategory? {
        let categories = try fetchAllCategories()
        return categories.first { $0.title == title }
    }

    func addCategory(_ category: TrackerCategory) throws {
        if let existingCategory = try fetchCategory(byTitle: category.title) {
            let updatedTrackers = existingCategory.trackers + category.trackers
            let updatedCategory = TrackerCategory(title: existingCategory.title, trackers: updatedTrackers)
            try updateCategory(updatedCategory)
        } else {
            try addCategoryToCoreData(category)
        }
        try saveContext()
        notifyChanges()
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        guard let categoryObject = try fetchCategoryEntity(byTitle: category.title) else { return }
        context.delete(categoryObject)
        try saveContext()
        notifyChanges()
    }
    
    func updateCategory(_ category: TrackerCategory) throws {
        guard let categoryObject = try fetchCategoryEntity(byTitle: category.title) else {
            throw NSError(domain: "TrackerCategoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Категория не найдена"])
        }
        configure(categoryObject, with: category)
        try saveContext()
        notifyChanges()
    }
    
    func updateCategory(from oldCategory: TrackerCategory, to newCategoryTitle: String, tracker: Tracker?) throws {
        // 1. Найти старую категорию в Core Data
        guard let oldCategoryObject = try fetchCategoryEntity(byTitle: oldCategory.title) else {
            throw NSError(domain: "TrackerCategoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Старая категория не найдена"])
        }
        
        // 2. Удалить трекер из старой категории, если он указан
        if let tracker = tracker {
            let trackersSet = oldCategoryObject.mutableSetValue(forKey: "trackers")
            if let existingTracker = trackersSet.first(where: {
                ($0 as? NSManagedObject)?.value(forKey: "id") as? UUID == tracker.id
            }) {
                trackersSet.remove(existingTracker)
            }
        }
        
        // 3. Найти или создать новую категорию
        if let newCategoryObject = try fetchCategoryEntity(byTitle: newCategoryTitle) {
            // Добавить трекер в существующую категорию
            if let tracker = tracker {
                let trackersSet = newCategoryObject.mutableSetValue(forKey: "trackers")
                trackersSet.add(createTrackerObject(from: tracker))
            }
        } else {
            // Создать новую категорию, если она не существует
            let newCategory = TrackerCategory(title: newCategoryTitle, trackers: tracker != nil ? [tracker!] : [])
            try addCategoryToCoreData(newCategory)
        }
        
        try saveContext()
        notifyChanges()
    }
    
    func renameCategory(from oldCategory: TrackerCategory, to newCategoryTitle: String) throws {
            guard let categoryObject = try fetchCategoryEntity(byTitle: oldCategory.title) else {
                throw NSError(domain: "TrackerCategoryStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Категория не найдена"])
            }
            
            categoryObject.setValue(newCategoryTitle, forKey: "title")
            try saveContext()
            notifyChanges()
        }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка выполнения запроса: \(error)")
        }
    }

    private func addCategoryToCoreData(_ category: TrackerCategory) throws {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw NSError(domain: "TrackerCategoryStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти описание сущности"])
        }
        let categoryObject = NSManagedObject(entity: entityDescription, insertInto: context)
        configure(categoryObject, with: category)
        try saveContext()
    }

    private func configure(_ categoryObject: NSManagedObject, with category: TrackerCategory) {
        categoryObject.setValue(category.title, forKey: "title")

        let trackersSet = categoryObject.mutableSetValue(forKey: "trackers")
        trackersSet.removeAllObjects()
        for tracker in category.trackers {
            trackersSet.add(createTrackerObject(from: tracker))
        }
    }

    private func createTrackerObject(from tracker: Tracker) -> NSManagedObject {
        let entityName = "TrackerCoreData"
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            fatalError("Не удалось найти описание сущности \(entityName)")
        }
        let trackerObject = NSManagedObject(entity: entityDescription, insertInto: context)
        configureTracker(trackerObject, with: tracker)
        return trackerObject
    }

    private func configureTracker(_ trackerObject: NSManagedObject, with tracker: Tracker) {
        trackerObject.setValue(tracker.id, forKey: "id")
        trackerObject.setValue(tracker.name, forKey: "name")
        trackerObject.setValue(tracker.emoji, forKey: "emoji")
        trackerObject.setValue(tracker.color.hexString, forKey: "color")
        let encoder = JSONEncoder()
        if let scheduleData = try? encoder.encode(tracker.schedule) {
            trackerObject.setValue(scheduleData, forKey: "schedule")
        }
    }

    private func convertToTrackerCategory(from categoryObject: NSManagedObject) -> TrackerCategory? {
        guard let title = categoryObject.value(forKey: "title") as? String else {
            return nil
        }

        let trackersSet = categoryObject.mutableSetValue(forKey: "trackers")
        let trackers = trackersSet.compactMap { trackerObject -> Tracker? in
            return convertToTracker(from: trackerObject as? NSManagedObject)
        }

        return TrackerCategory(title: title, trackers: trackers)
    }

    private func convertToTracker(from trackerObject: NSManagedObject?) -> Tracker? {
        guard let trackerObject = trackerObject else { return nil }
        guard let id = trackerObject.value(forKey: "id") as? UUID,
              let name = trackerObject.value(forKey: "name") as? String,
              let emoji = trackerObject.value(forKey: "emoji") as? String,
              let colorHex = trackerObject.value(forKey: "color") as? String,
              let color = UIColor(hexString: colorHex),
              let scheduleData = trackerObject.value(forKey: "schedule") as? Data else {
            return nil
        }

        let schedule = (try? JSONDecoder().decode(Set<Weekday>.self, from: scheduleData)) ?? []
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule, isPinned: false)
    }

    private func fetchCategoryEntity(byTitle title: String) throws -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        let result = try context.fetch(fetchRequest)
        return result.first
    }

    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
