import UIKit

protocol HabitsNavigationDelegate: AnyObject {
    func showCategoryScreen()
    func showScheduleScreen(currentlySelectedDays: Set<Weekday>)
}

final class HabitsControllerCoordinator: BaseCoordinator {
  
    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    
    private var categoryCoordinator: CategoryCoordinator?
    private var scheduleCoordinator: ScheduleCoordinator?
    
    weak var createHabitsDelegate: CreateHabitsControllerDelegate?
    weak var context: HabitsController?

    init(
        navigationController: UINavigationController,
        dependencies: CoordinatorDependencies,
        screenFactory: ScreenFactory
    ) {
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 HabitsControllerCoordinator.start() вызван")
        
        let habitVC = screenFactory.makeHabitsScreen(navigationDelegate: self)
        habitVC.createHabitsDelegate = createHabitsDelegate 
        context = habitVC
        show(habitVC)
    }
}

extension HabitsControllerCoordinator: HabitsNavigationDelegate {
    func showCategoryScreen() {
        print("🟢 HabitsControllerCoordinator: showCategoryScreen вызван")
        let categoryCoordinator = CategoryCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory
        )
        
        categoryCoordinator.habitsController = context
        childCoordinators.append(categoryCoordinator)
        categoryCoordinator.start()
    }
    
    func showScheduleScreen(currentlySelectedDays: Set<Weekday>) {
        print("🟢 HabitsControllerCoordinator: showScheduleScreen вызван с днями: \(currentlySelectedDays)")
    
        let scheduleCoordinator = ScheduleCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory
        )
    
        scheduleCoordinator.habitsController = context
        childCoordinators.append(scheduleCoordinator)
        scheduleCoordinator.start(selectedDays: currentlySelectedDays)
    }
}

extension HabitsControllerCoordinator {
    func updateScheduleButton(subtitle: String?) {
        context?.scheduleButton.update(title: "Расписание", subtitle: subtitle)
    }

    func updateCategoryButton(subtitle: String?) {
        context?.categoryButton.update(title: "Категория", subtitle: subtitle)
    }
}
