import Foundation
import UIKit

final class ScheduleCoordinator: BaseCoordinator {

    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    
    private var context: ScheduleViewController?
    weak var habitsController: HabitsController?

    init(
        navigationController: UINavigationController,
        dependencies: CoordinatorDependencies,
        screenFactory: ScreenFactory
    ) {
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        super.init(navigationController: navigationController)
    }

    func start(selectedDays: Set<Weekday>) {
        print("🟢 ScheduleCoordinator: start() вызван с выбранными днями: \(selectedDays)")

        let viewController = screenFactory.makeScheduleScreen(
            selectedDays: selectedDays,
            delegate: self,
            coordinator: self
        )

        context = viewController
        show(viewController)
    }

    func updateScheduleScreen() {
        context?.updateTableView()
    }

    func updateDoneButtonState(_ isEnabled: Bool) {
        context?.updateDoneButtonState(isEnabled)
    }

    func closeScheduleScreen() {
        context?.dismiss(animated: true)
    }
}

extension ScheduleCoordinator: ScheduleViewControllerDelegate {
    func didSelect(days: Set<Weekday>) {
        habitsController?.updateSelectedSchedule(days: days) 
        closeScheduleScreen()
    }
}
