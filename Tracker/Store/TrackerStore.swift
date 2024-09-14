//
//  TrackerStore.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import UIKit
import CoreData

final class TrackerStore {
    
    private let context: NSManagedObjectContext
    let trackerRecordStore: TrackerRecordStore
    
    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trackerRecordStore = TrackerRecordStore(context: context)
        self.init(context: context, trackerRecordStore: trackerRecordStore)
    }

    init(context: NSManagedObjectContext, trackerRecordStore: TrackerRecordStore) {
        self.context = context
        self.trackerRecordStore = trackerRecordStore
    }

    func addNewTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        configure(trackerCoreData, with: tracker)
        try saveContext()
    }

    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) throws {
        configure(trackerCoreData, with: tracker)
        try saveContext()
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) throws {
        
        do {
            try trackerRecordStore.deleteRecords(for: tracker.id!)
        } catch {
            print("Ошибка при удалении записей трекера: \(error)")
            throw error
        }

        context.delete(tracker)

        do {
            try saveContext()
        } catch {
            print("Ошибка при сохранении контекста после удаления трекера: \(error)")
            throw error
        }
    }

    func fetchAllTrackers() throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackerCoreDataList = try context.fetch(fetchRequest)
        return trackerCoreDataList.compactMap { convertToTracker(from: $0) }
    }

    private func configure(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        let encoder = JSONEncoder()
        trackerCoreData.schedule = try? encoder.encode(tracker.schedule)
    }
    
    func fetchTracker(by id: UUID) throws -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
        let result = try context.fetch(fetchRequest)
        return result.first
    }
    
    func convertToTracker(from coreDataTracker: TrackerCoreData) -> Tracker? {
        guard let id = coreDataTracker.id,
              let name = coreDataTracker.name,
              let emoji = coreDataTracker.emoji,
              let colorHex = coreDataTracker.color,
              let color = UIColor(hexString: colorHex),
              let scheduleData = coreDataTracker.schedule else { return nil }

        let schedule = (try? JSONDecoder().decode(Set<Weekday>.self, from: scheduleData)) ?? []
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }

    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
