import Foundation

// MARK: - Localization
extension Weekday {
    var shortName: String {
        switch self {
        case .monday: return NSLocalizedString("monday", comment: "Short name for Monday")
        case .tuesday: return NSLocalizedString("tuesday", comment: "Short name for Tuesday")
        case .wednesday: return NSLocalizedString("wednesday", comment: "Short name for Wednesday")
        case .thursday:  return NSLocalizedString("thursday", comment: "Short name for Thursday")
        case .friday: return NSLocalizedString("friday", comment: "Short name for Friday")
        case .saturday: return NSLocalizedString("saturday", comment: "Short name for Saturday")
        case .sunday: return NSLocalizedString("sunday", comment: "Short name for Sunday")
        }
    }
}

// MARK: - Current Day
extension Weekday {
    static var current: Weekday {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: Date()) 
        return Weekday.allCases[(weekdayIndex - calendar.firstWeekday + 7) % 7]
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let trackerUpdated = Notification.Name("trackerUpdated")
}


