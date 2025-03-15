import Foundation
import UIKit

protocol StatisticsServiceProtocol {
    func makeStatisticsViewModel() -> StatViewModel
}

final class StatisticsService: StatisticsServiceProtocol {
    private let trackerStore: TrackerStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol

    init(trackerStore: TrackerStoreProtocol, trackerRecordStore: TrackerRecordStoreProtocol) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
    }

    func makeStatisticsViewModel() -> StatViewModel {
        return StatViewModel(trackerStore: trackerStore, trackerRecordStore: trackerRecordStore)
    }
}
