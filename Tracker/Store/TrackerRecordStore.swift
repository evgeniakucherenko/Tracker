//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import CoreData

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private let entityName = "TrackerRecordCoreData"

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public Methods
    func fetchAllTrackerRecords() throws -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let trackerRecordObjects = try context.fetch(fetchRequest)
        return trackerRecordObjects.compactMap { convertToTrackerRecord(from: $0) }
    }

    func addTrackerRecord(_ record: TrackerRecord) throws {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw NSError(domain: "TrackerRecordStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти описание сущности"])
        }
            
        let trackerRecordObject = NSManagedObject(entity: entityDescription, insertInto: context)
        configure(trackerRecordObject, with: record)
        
        try saveContext()
    }

    // MARK: - Private Methods
    private func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }

    private func convertToTrackerRecord(from recordObject: NSManagedObject) -> TrackerRecord? {
        guard let id = recordObject.value(forKey: "id") as? UUID,
              let date = recordObject.value(forKey: "date") as? Date else {
                return nil
        }
        return TrackerRecord(id: id, date: date)
    }
       
    private func configure(_ recordObject: NSManagedObject, with trackerRecord: TrackerRecord) {
        recordObject.setValue(trackerRecord.id, forKey: "id")
        recordObject.setValue(trackerRecord.date, forKey: "date")
    }
}


