import UIKit

final class ScheduleViewModel {
    // MARK: - Properties
    private(set) var selectedDays: Set<Weekday> = [] {
        didSet {
            onDaysUpdated?(selectedDays)
        }
    }
    
    var onDaysUpdated: Binding<Set<Weekday>>?
    
    var numberOfDays: Int {
        return Weekday.allCases.count
    }
    
    init(initialSelectedDays: Set<Weekday>) {
        self.selectedDays = initialSelectedDays
    }
    
    // MARK: - Public Methods
    func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
    
    func getDay(at index: Int) -> Weekday {
        return Weekday.allCases[index]
    }
    
    func isDaySelected(at index: Int) -> Bool {
        let day = Weekday.allCases[index]
        return selectedDays.contains(day)
    }
    
    func isDoneButtonEnabled() -> Bool {
        return !selectedDays.isEmpty
    }
}
