//
//  TrackerStore.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import UIKit
import CoreData

final class TrackerStore: NSObject, 
                          TrackerStoreProtocol,
                          NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<NSManagedObject>
    private var onChangeCallback: (() -> Void)?
    private let entityName = "TrackerCoreData"
    let trackerRecordStore: TrackerRecordStoreProtocol
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext, trackerRecordStore: TrackerRecordStoreProtocol) {
        self.context = context
        self.trackerRecordStore = trackerRecordStore
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
    
        self.fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выполнении запроса: \(error)")
        }
    }

    // MARK: - Tracker Management
    func addNewTracker(_ tracker: Tracker) throws {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw NSError(domain: "TrackerStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти описание сущности"])
        }

        let trackerObject = NSManagedObject(entity: entityDescription, insertInto: context)
        configure(trackerObject, with: tracker)

        do {
            try saveContext()
        } catch {
            print("[addNewTracker] Ошибка при сохранении контекста: \(error)")
            throw error
        }
        notifyChanges()
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            throw NSError(domain: "FetchError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки трекеров"])
        }
        return fetchedObjects.compactMap { convertToTracker(from: $0) }
    }

    func fetchTracker(by id: UUID) throws -> Tracker? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first.flatMap { convertToTracker(from: $0) }
    }

    // MARK: - Tracker Completion Management
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) throws {
        let trackerRecords = try trackerRecordStore.fetchAllTrackerRecords()
        let today = Calendar.current.startOfDay(for: date)
        
        if trackerRecords.contains(where: {
            $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: today)
        }) {
            return
        } else {
            let newRecord = TrackerRecord(id: tracker.id, date: today)
            try trackerRecordStore.addTrackerRecord(newRecord)
        }
        
        notifyChanges()
    }
    
    func getCompletionCount(for tracker: Tracker) throws -> Int {
        let trackerRecords = try trackerRecordStore.fetchAllTrackerRecords()
        let completionDates = Set(trackerRecords.filter { $0.id == tracker.id }.map { $0.date })
        return completionDates.count
    }
    
    // MARK: - Tracker Record Management
    func fetchAllTrackerRecords() throws -> [TrackerRecord] {
        return try trackerRecordStore.fetchAllTrackerRecords()
    }

    // MARK: - Core Data Saving
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    // MARK: - Helper Methods
    private func configure(_ trackerObject: NSManagedObject, with tracker: Tracker) {
        trackerObject.setValue(tracker.id, forKey: "id")
        trackerObject.setValue(tracker.name, forKey: "name")
        trackerObject.setValue(tracker.emoji, forKey: "emoji")
        trackerObject.setValue(tracker.color.hexString, forKey: "color")

        let encoder = JSONEncoder()
        if let scheduleData = try? encoder.encode(tracker.schedule) {
            trackerObject.setValue(scheduleData, forKey: "schedule")
        }
    }
    
    private func convertToTracker(from trackerObject: NSManagedObject) -> Tracker? {
        guard let id = trackerObject.value(forKey: "id") as? UUID,
              let name = trackerObject.value(forKey: "name") as? String,
              let emoji = trackerObject.value(forKey: "emoji") as? String,
              let colorHex = trackerObject.value(forKey: "color") as? String,
              let color = UIColor(hexString: colorHex),
              let scheduleData = trackerObject.value(forKey: "schedule") as? Data else {
            return nil
        }

        let schedule = (try? JSONDecoder().decode(Set<Weekday>.self, from: scheduleData)) ?? []
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }

    // MARK: - Change Handling
    func subscribeToChanges(_ onChange: @escaping () -> Void) {
        self.onChangeCallback = onChange
    }
    
    private func notifyChanges() {
        onChangeCallback?()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyChanges()
    }
}


