//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import CoreData
import UIKit

final class TrackerRecordStore {

    let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }
        
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        try saveContext()
    }

    func deleteRecords(for trackerId: UUID) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        let records = try context.fetch(fetchRequest)
        for record in records {
            context.delete(record)
        }
        try saveContext()
    }

    func fetchAllTrackerRecords() throws -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let trackerRecordCoreDataList = try context.fetch(fetchRequest)
        return trackerRecordCoreDataList.compactMap { convertToTrackerRecord(from: $0) }
    }

    func deleteTrackerRecord(for trackerId: UUID, on date: Date) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerId as CVarArg, date as NSDate)
        let records = try context.fetch(fetchRequest)
        for record in records {
            context.delete(record)
        }
        try saveContext()
    }
    
    func convertToTrackerRecord(from coreDataRecord: TrackerRecordCoreData) -> TrackerRecord {
        return TrackerRecord(id: coreDataRecord.id ?? UUID(), date: coreDataRecord.date ?? Date())
    }

    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
