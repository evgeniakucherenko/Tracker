import Foundation

// Протокол для переходов между экранами
protocol HabitsNavigationDelegate: AnyObject {
    func showCategoryScreen()
    func showScheduleScreen(currentlySelectedDays: Set<Weekday>) 
}
