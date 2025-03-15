import Foundation
import UIKit

protocol CreateTrackerControllerNavigationDelegate: AnyObject {
    func startHabitsFlow()
    func showIrregularEvent(delegate: IrregularEventControllerDelegate?)
}

final class CreateTrackerCoordinator: BaseCoordinator {

    private let dependencies: CoordinatorDependencies
    weak var delegate: CreateTrackerControllerDelegate?
    
    private var habitsCoordinator: HabitsControllerCoordinator? // Нужно убрать это свойство?
    private let screenFactory: ScreenFactory
    
    init(navigationController: UINavigationController,
         dependencies: CoordinatorDependencies,
         screenFactory: ScreenFactory) {
        
        self.dependencies = dependencies
        self.screenFactory = screenFactory 
        
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 CreateTrackerCoordinator включился")

        let controller = CreateTrackerController(categoryStore: dependencies.categoryStore)
        controller.navigationDelegate = self 
        controller.delegate = delegate

        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .formSheet
        navigationController.present(navController, animated: true)
    }


    func startHabitsFlow() {
        print("🟢 Координатор CreateTrackerCoordinator: startHabitsFlow")

        let categoryCoordinator = CategoryCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory,
            onCategorySelected: { [weak self] selectedCategory in
                print("✅ Выбрана категория: \(selectedCategory)")
                self?.habitsCoordinator?.handleSelectedCategory(selectedCategory)
            }
        )

        let habitsCoordinator = HabitsControllerCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory,
            categoryCoordinator: categoryCoordinator,
            onCategorySelected: { selectedCategory in
                print("🟢 HabitsControllerCoordinator получил категорию: \(selectedCategory)")
            }
        )

        self.habitsCoordinator = habitsCoordinator

        let habitsController = screenFactory.makeHabitsScreen(navigationDelegate: habitsCoordinator)
        show(habitsController, asModal: false)
        habitsCoordinator.start()
    }

    // Пока не реализовываем
    func showIrregularEvent(delegate: IrregularEventControllerDelegate?) { // с этим пока не работаю
        
        print("🟢 Координатор CreateTrackerCoordinator: showIrregularEvent")
        
        let viewModel = IrregularEventViewModel(categoryStore: dependencies.categoryStore)
        let controller = IrregularEventController(viewModel: viewModel)
        controller.irregularEventDelegate = delegate
        
        let navController = UINavigationController(rootViewController: controller)
        
        let targetController = navigationController.presentedViewController ?? navigationController
        targetController.present(navController, animated: true)
    }
}

extension CreateTrackerCoordinator: CreateTrackerControllerNavigationDelegate {}
