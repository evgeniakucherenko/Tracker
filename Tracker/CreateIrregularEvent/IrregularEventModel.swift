import UIKit

final class IrregularEventViewModel: BaseCreateTrackerViewModel {
    private var categoryStore: TrackerCategoryStoreProtocol
    private var trackerRecords: [TrackerRecord] = []

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
    }

    override func createTracker() -> (Tracker, String)? {
        guard let (tracker, category) = super.createTracker() else { return nil }

        let currentDate = Date()
        let trackerRecord = TrackerRecord(id: tracker.id, date: currentDate)
        saveTrackerRecord(trackerRecord)

        return (tracker, category)
    }

    private func saveTrackerRecord(_ record: TrackerRecord) {
        trackerRecords.append(record)
    }

    var categoryStoreRef: TrackerCategoryStoreProtocol {
        return categoryStore
    }
}
