import UIKit

final class DateService: DateServiceProtocol {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func weekday(from date: Date, mapping: [Int: Weekday]) -> Weekday? {
        let weekdayNumber = calendar.component(.weekday, from: date)
        return mapping[weekdayNumber]
    }

    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        return calendar.isDate(date1, inSameDayAs: date2)
    }

    func isPastOrToday(_ date: Date) -> Bool {
        return date <= Date()
    }
}
