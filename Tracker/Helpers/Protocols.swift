//
//  Protocols.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 15.09.2024.
//

import Foundation

// Категории
// Протокол для передачи информации о созданной категории
protocol CategoryCreationDelegate: AnyObject {
    func didCreateCategory(_ categoryName: String)
}

// Протокол для передачи информации о выбранной категории
protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ categoryName: String)
}

// Трекеры 
// Протокол для передачи информации о созданной привычке
protocol CreateHabitsControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String)
}

// Протокол для передачи информации о созданном нерегулярном событии
protocol IrregularEventControllerDelegate: AnyObject {
    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String)
}

// Протокол для передачи информации о созданном трекере
protocol CreateTrackerControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String)
    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String)
}

// Расписание
// Протокол для передачи информации о выбранном расписании
protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelect(days: Set<Weekday>)
}

protocol TrackerStoreProtocol {
    func fetchAllTrackers() throws -> [Tracker]
    func addNewTracker(_ tracker: Tracker) throws
    func fetchTracker(by id: UUID) throws -> TrackerCoreData?
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) throws
    func getCompletionCount(for tracker: Tracker) throws -> Int
    func fetchAllTrackerRecords() throws -> [TrackerRecord]
    func subscribeToChanges(_ onChange: @escaping () -> Void)
}

protocol TrackerRecordStoreProtocol {
    func fetchAllTrackerRecords() throws -> [TrackerRecord]
    func addTrackerRecord(_ record: TrackerRecord) throws
    func saveContext() throws
    
}

protocol TrackerCategoryStoreProtocol {
    func fetchAllCategories() throws -> [TrackerCategory]
    func addCategory(_ category: TrackerCategory) throws
    func deleteCategory(_ category: TrackerCategory) throws
    func updateCategory(_ category: TrackerCategory) throws
    func subscribeToChanges(_ onChange: @escaping () -> Void)
    func fetchCategory(byTitle title: String) throws -> TrackerCategoryCoreData?
}
