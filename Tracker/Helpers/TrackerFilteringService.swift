import UIKit

final class TrackerFilteringService: TrackerFilteringServiceProtocol {
    func filteredCategories(
        categories: [TrackerCategory],
        pinnedTrackers: [Tracker],
        completedTrackers: Set<UUID>,
        currentDate: Date,
        weekdayMapping: [Int: Weekday],
        currentFilterIndex: Int
    ) -> [TrackerCategory] {

        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        guard let weekday = weekdayMapping[selectedDayOfWeek] else {
            return []
        }

        // Универсальная фильтрация по дню недели — используется во "Все трекеры" и "На сегодня"
        let filterByWeekday: ([TrackerCategory]) -> [TrackerCategory] = { categories in
            categories.compactMap { category in
                let trackersForSelectedDay = category.trackers.filter { tracker in
                    tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
                }
                return trackersForSelectedDay.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackersForSelectedDay)
            }
        }

        switch currentFilterIndex {
        case 0: // "Все трекеры"
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinned", comment: ""),
                trackers: pinnedTrackers
            )
            let result = pinnedCategory.trackers.isEmpty ? categories : [pinnedCategory] + categories
            return result

        case 1: // "Трекеры на сегодня"
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinned", comment: ""),
                trackers: pinnedTrackers.filter { tracker in
                    tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
                }
            )
            let filteredRegular = filterByWeekday(categories)
            return pinnedCategory.trackers.isEmpty ? filteredRegular : [pinnedCategory] + filteredRegular

        case 2: // "Завершенные"
            let completedFiltered = categories.compactMap { category in
                let completedTrackersInCategory = category.trackers.filter { completedTrackers.contains($0.id) }
                return completedTrackersInCategory.isEmpty ? nil : TrackerCategory(title: category.title, trackers: completedTrackersInCategory)
            }
            // Пиннутые в завершенных
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinned", comment: ""),
                trackers: pinnedTrackers.filter { completedTrackers.contains($0.id) }
            )
            return pinnedCategory.trackers.isEmpty ? completedFiltered : [pinnedCategory] + completedFiltered

        case 3: // "Не завершенные"
            let notCompletedFiltered = categories.compactMap { category in
                let notCompletedTrackersInCategory = category.trackers.filter { !completedTrackers.contains($0.id) }
                return notCompletedTrackersInCategory.isEmpty ? nil : TrackerCategory(title: category.title, trackers: notCompletedTrackersInCategory)
            }
            // Пиннутые в незавершенных
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinned", comment: ""),
                trackers: pinnedTrackers.filter { !completedTrackers.contains($0.id) }
            )
            return pinnedCategory.trackers.isEmpty ? notCompletedFiltered : [pinnedCategory] + notCompletedFiltered

        default:
            // По умолчанию возвращаем просто все категории + пиннутые
            let pinnedCategory = TrackerCategory(
                title: NSLocalizedString("pinned", comment: ""),
                trackers: pinnedTrackers
            )
            return pinnedCategory.trackers.isEmpty ? categories : [pinnedCategory] + categories
        }
    }
}
