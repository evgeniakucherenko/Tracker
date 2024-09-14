//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore {
    
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) {
        self.context = context
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        
        categoryCoreData.title = category.title
        
        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            configure(trackerCoreData, with: tracker)
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        try saveContext()
    }

    func deleteCategory(_ categoryCoreData: TrackerCategoryCoreData) throws {
        context.delete(categoryCoreData)
        try saveContext()
    }

    func updateCategory(_ categoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) throws {
        categoryCoreData.title = category.title
        
        categoryCoreData.removeFromTrackers(categoryCoreData.trackers ?? NSSet())
        for tracker in category.trackers {
            let trackerCoreData = TrackerCoreData(context: context)
            configure(trackerCoreData, with: tracker)
            categoryCoreData.addToTrackers(trackerCoreData)
        }
        
        try saveContext()
    }

    func fetchAllCategories() throws -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(fetchRequest)
    }
    
    func fetchCategory(byTitle title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        let result = try context.fetch(fetchRequest)
        return result.first
    }

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
}
