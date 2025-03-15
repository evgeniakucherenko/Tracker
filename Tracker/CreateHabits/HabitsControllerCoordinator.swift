import UIKit

final class HabitsControllerCoordinator: BaseCoordinator, HabitsNavigationDelegate {
    
    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    private var categoryCoordinator: CategoryCoordinator?
    var onCategorySelected: ((String) -> Void)?
    
    private var habitsController: HabitsController?
    
    init(
            navigationController: UINavigationController,
            dependencies: CoordinatorDependencies,
            screenFactory: ScreenFactory,
            categoryCoordinator: CategoryCoordinator? = nil,
            onCategorySelected: @escaping (String) -> Void
        ) {
            self.dependencies = dependencies
            self.screenFactory = screenFactory
            self.categoryCoordinator = categoryCoordinator 
            self.onCategorySelected = onCategorySelected
            super.init(navigationController: navigationController)
        }
    
    // Где лучше создавать HabitsController? Сейчас создается в CreateTrackerController 
    override func start() {
        print("🟢 HabitsControllerCoordinator.start() вызван")
    }
    
    func showCategoryScreen() {
        print("🟢 HabitsControllerCoordinator: showCategoryScreen вызван")

        let categoryCoordinator = CategoryCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory,
            onCategorySelected: { [weak self] selectedCategory in
                print("🟢 Категория выбрана: \(selectedCategory)")
                self?.handleSelectedCategory(selectedCategory)
            }
        )

        self.categoryCoordinator = categoryCoordinator
        categoryCoordinator.start() 
    }
    
    func handleSelectedCategory(_ category: String) {
        print("🟢 HabitsControllerCoordinator: обработка выбранной категории \(category)")

        habitsController?.didSelectCategory(category)
        navigationController.dismiss(animated: true)
    }

    func showScheduleScreen(currentlySelectedDays selectedDays: Set<Weekday>) {
        print("🟢 HabitsControllerCoordinator: showScheduleScreen будет вызван")
    }
}

extension HabitsControllerCoordinator: CategorySelectionDelegate {
    
    func didSelectCategory(_ category: String) {
        print("🟢 HabitsControllerCoordinator: Выбрана категория \(category)")
    }
}
