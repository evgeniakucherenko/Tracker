//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject, 
                                  NSFetchedResultsControllerDelegate,
                                  TrackerCategoryStoreProtocol  {

    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    private var onChangeCallback: (() -> Void)?
    
    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    // MARK: - Fetch Methods
    func fetchAllCategories() throws -> [TrackerCategory] {
        guard let fetchedCategories = fetchedResultsController.fetchedObjects else {
            throw NSError(domain: "FetchError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки категорий"])
        }
        return fetchedCategories.map { convertToTrackerCategory(from: $0) }
    }

    func fetchCategory(byTitle title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        let result = try context.fetch(fetchRequest)
        print("[TrackeсCategoryStore - fetch] Метод сработал")
        return result.first
    }

    // MARK: - FetchedResultsController Setup
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка выполнения запроса: \(error)")
        }
    }

    // MARK: - Core Data Save
    private func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                throw error
            }
        }
    }
    
    // MARK: - Add, Delete, Update Category
    func addCategory(_ category: TrackerCategory) throws {
        
        if let existingCategory = try fetchCategory(byTitle: category.title) {
            
            for tracker in category.trackers {
                let trackerCoreData = TrackerCoreData(context: context)
                configure(trackerCoreData, with: tracker)
                existingCategory.addToTrackers(trackerCoreData)
            }
            
            try saveContext()
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        
        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            configure(trackerCoreData, with: tracker)
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        try saveContext()
        notifyChanges()
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        guard let coreDataCategory = try fetchCategory(byTitle: category.title) else { return }
        context.delete(coreDataCategory)
        
        try saveContext()
        notifyChanges()
    }
    
    func updateCategory(_ category: TrackerCategory) throws {
        guard let categoryCoreData = try fetchCategory(byTitle: category.title) else { return }
        categoryCoreData.title = category.title
        
        categoryCoreData.removeFromTrackers(categoryCoreData.trackers ?? NSSet())
        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            configure(trackerCoreData, with: tracker)
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        try saveContext()
        notifyChanges()
    }
    
    // MARK: - Helper Methods
    private func configure(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        let encoder = JSONEncoder()
        do {
            trackerCoreData.schedule = try encoder.encode(tracker.schedule)
        } catch {
            print("[TrackerStore] Ошибка кодирования расписания: \(error)")
        }
    }

    func convertToTrackerCategory(from coreDataCategory: TrackerCategoryCoreData) -> TrackerCategory {
        let trackers = (coreDataCategory.trackers?.allObjects as? [TrackerCoreData])?.map { coreDataTracker in
            return Tracker(
                id: coreDataTracker.id ?? UUID(),
                name: coreDataTracker.name ?? "",
                color: UIColor(hexString: coreDataTracker.color ?? "") ?? .black,
                emoji: coreDataTracker.emoji ?? "",
                schedule: (try? JSONDecoder().decode(Set<Weekday>.self, from: coreDataTracker.schedule ?? Data())) ?? []
            )
        } ?? []
        return TrackerCategory(title: coreDataCategory.title ?? "", trackers: trackers)
    }
    
    // MARK: - Change Handling
    private func notifyChanges() {
        onChangeCallback?()
    }

    func subscribeToChanges(_ onChange: @escaping () -> Void) {
        onChangeCallback = onChange
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyChanges()
    }
}



