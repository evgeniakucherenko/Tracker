import Foundation

struct StatItem {
    let value: String
    let description: String
}

final class StatViewModel {
    // MARK: - Dependencies
    private let trackerStore: TrackerStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol

    // MARK: - Init
    init(trackerStore: TrackerStoreProtocol, trackerRecordStore: TrackerRecordStoreProtocol) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
    }

    // MARK: - Public Properties
    private(set) var bestPeriod: Int = 0
    private(set) var perfectDays: Int = 0
    private(set) var totalCompletedTrackers: Int = 0
    private(set) var averageValue: Int = 0
    
    // MARK: - Public Methods
    func calculateStatistics() async {
            do {
                let allTrackers = try await trackerStore.fetchAllTrackers()
                let allRecords = try await trackerRecordStore.fetchAllTrackerRecords()
    
                bestPeriod = calculateBestPeriod(from: allRecords)
                perfectDays = calculatePerfectDays(from: allTrackers, records: allRecords)
                totalCompletedTrackers = allRecords.count
                averageValue = calculateAverageValue(from: allTrackers, records: allRecords)
            } catch {
                print("Ошибка при расчете статистики: \(error.localizedDescription)")
            }
        }

    // MARK: - Private Methods
    private func calculateBestPeriod(from records: [TrackerRecord]) -> Int {
        let sortedDates = records.map { $0.date }.sorted()
        var bestPeriod = 0
        var currentPeriod = 1

        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            let dayDifference = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0

            if dayDifference == 1 {
                currentPeriod += 1
            } else {
                bestPeriod = max(bestPeriod, currentPeriod)
                currentPeriod = 1
            }
        }
        
        return max(bestPeriod, currentPeriod)
    }

    private func calculatePerfectDays(from trackers: [Tracker], records: [TrackerRecord]) -> Int {
        var perfectDays = 0
        let groupedByDate = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })
        
        for (_, recordsOnDay) in groupedByDate {
            let uniqueTrackerIDs = Set(recordsOnDay.map { $0.id })
            if uniqueTrackerIDs.count == trackers.count {
                perfectDays += 1
            }
        }
        
        return perfectDays
    }

    private func calculateAverageValue(from trackers: [Tracker], records: [TrackerRecord]) -> Int {
        guard !trackers.isEmpty else { return 0 }
        let average = Double(records.count) / Double(trackers.count)
        return Int(round(average))
    }

    func getTotalCompletedTrackers() -> Int {
        return totalCompletedTrackers
    }

    // MARK: - Helper Methods
    func numberOfItems() -> Int {
        return 4 
    }

    func getItem(at index: Int) -> StatItem {
        switch index {
        case 0:
            return StatItem(value: "\(bestPeriod)", description: NSLocalizedString("bestPeriod", comment: "Лучший период"))
        case 1:
            return StatItem(value: "\(perfectDays)", description: NSLocalizedString("perfectDays", comment: "Идеальные дни"))
        case 2:
            return StatItem(value: "\(totalCompletedTrackers)", description: NSLocalizedString("completedTrackers", comment: "Трекеров завершено"))
        case 3:
            return StatItem(value: "\(averageValue)", description: NSLocalizedString("averageValue", comment: "Среднее значение"))
        default:
            return StatItem(value: "0", description: "")
        }
    }
}
