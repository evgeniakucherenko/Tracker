import UIKit

final class ScheduleViewModel {

    var coordinator: ScheduleCoordinator?

    private(set) var selectedDays: Set<Weekday> {
        didSet {
            coordinator?.updateScheduleScreen()
            coordinator?.updateDoneButtonState(isDoneButtonEnabled())
        }
    }

    var numberOfDays: Int {
        return Weekday.allCases.count
    }

    init(initialSelectedDays: Set<Weekday>) {
        self.selectedDays = initialSelectedDays
        DispatchQueue.main.async { [weak self] in
            self?.coordinator?.updateScheduleScreen()
            self?.coordinator?.updateDoneButtonState(self?.isDoneButtonEnabled() ?? false)
        }
    }

    // Метод для получения дня по индексу
    func getDay(at index: Int) -> Weekday {
        return Weekday.allCases[index]
    }

    // Метод для проверки, выбран ли день
    func isDaySelected(at index: Int) -> Bool {
        return selectedDays.contains(getDay(at: index))
    }

    func getSelectedDays() -> Set<Weekday> {
        return selectedDays
    }

    func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }

    func isDoneButtonEnabled() -> Bool {
        return !selectedDays.isEmpty
    }
}
















//final class ScheduleViewModel {
//    
//    // MARK: - Properties
//    var coordinator: ScheduleCoordinator? // Теперь ViewModel знает о координаторе
//
//    private(set) var selectedDays: Set<Weekday> {
//        didSet {
//            print("🟢 ScheduleViewModel: обновление дней \(selectedDays)")
//            coordinator?.updateScheduleScreen()
//            coordinator?.updateDoneButtonState(isDoneButtonEnabled())
//        }
//    }
//    
//    var numberOfDays: Int {
//        return Weekday.allCases.count
//    }
//    
//    // MARK: - Initializer
//    init(initialSelectedDays: Set<Weekday>) {
//        self.selectedDays = initialSelectedDays
//    }
//    
//    // MARK: - Public Methods
//    // ✅ Добавляем метод для получения выбранных дней
//      func getSelectedDays() -> Set<Weekday> {
//          return selectedDays
//      }
//    
//    
//    func toggleDay(_ day: Weekday) {
//        if selectedDays.contains(day) {
//            selectedDays.remove(day)
//        } else {
//            selectedDays.insert(day)
//        }
//    }
//    
//    func getDay(at index: Int) -> Weekday {
//        return Weekday.allCases[index]
//    }
//    
//    func isDaySelected(at index: Int) -> Bool {
//        return selectedDays.contains(getDay(at: index))
//    }
//    
//    func isDoneButtonEnabled() -> Bool {
//        return !selectedDays.isEmpty
//    }
//}


//final class ScheduleViewModel {
//    
//    // MARK: - Properties
//    lazy var onDaysUpdated: ((Set<Weekday>) -> Void)? = nil
//    lazy var onDoneButtonStateChange: ((Bool) -> Void)? = nil
//    
//    private(set) var selectedDays: Set<Weekday> {
//        didSet {
//            onDaysUpdated?(selectedDays)
//            onDoneButtonStateChange?(isDoneButtonEnabled())
//        }
//    }
//    
//    var numberOfDays: Int {
//        return Weekday.allCases.count
//    }
//    
//    // MARK: - Initializer
//    init(initialSelectedDays: Set<Weekday>) {
//        self.selectedDays = initialSelectedDays
//    }
//    
//    // MARK: - Public Methods
//    func toggleDay(_ day: Weekday) {
//        if selectedDays.contains(day) {
//            selectedDays.remove(day)
//        } else {
//            selectedDays.insert(day)
//        }
//    }
//    
//    func getDay(at index: Int) -> Weekday {
//        return Weekday.allCases[index]
//    }
//    
//    func isDaySelected(at index: Int) -> Bool {
//        return selectedDays.contains(getDay(at: index))
//    }
//    
//    func isDoneButtonEnabled() -> Bool {
//        return !selectedDays.isEmpty
//    }
//}
