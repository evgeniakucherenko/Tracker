//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import CoreData
import UIKit

final class TrackerRecordStore: TrackerRecordStoreProtocol {
    
    let context: NSManagedObjectContext

    convenience init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Tracker Record Management
    func fetchAllTrackerRecords() throws -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let trackerRecordCoreDataList = try context.fetch(fetchRequest)
        return trackerRecordCoreDataList.compactMap { convertToTrackerRecord(from: $0) }
    }
    
    func addTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
        try saveContext()
    }

    // MARK: - Conversion Methods
    func convertToTrackerRecord(from coreDataRecord: TrackerRecordCoreData) -> TrackerRecord? {
        guard let id = coreDataRecord.id, let date = coreDataRecord.date else { return nil }
        return TrackerRecord(id: id, date: date)
    }
    
    // MARK: - Core Data Save
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
