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
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    private var onChangeCallback: (() -> Void)?
    let trackerRecordStore: TrackerRecordStoreProtocol
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext, trackerRecordStore: TrackerRecordStoreProtocol) {
        self.context = context
        self.trackerRecordStore = trackerRecordStore
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
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
        
        let trackerCoreData = TrackerCoreData(context: context)
        configure(trackerCoreData, with: tracker)

        do {
            try saveContext()
            print("[addNewTracker] Контекст успешно сохранен.")
        } catch {
            print("[addNewTracker] Ошибка при сохранении контекста: \(error)")
            throw error
        }
        notifyChanges()
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        guard let fetchedTrackers = fetchedResultsController.fetchedObjects else {
            throw NSError(domain: "FetchError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Ошибка загрузки трекеров"])
        }
        return fetchedTrackers.compactMap { convertToTracker(from: $0) }
    }
    
    func fetchTracker(by id: UUID) throws -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = try context.fetch(fetchRequest)
        return result.first
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
        
        try trackerRecordStore.saveContext()
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
    private func configure(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color.hexString
        let encoder = JSONEncoder()
        trackerCoreData.schedule = try? encoder.encode(tracker.schedule)
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

