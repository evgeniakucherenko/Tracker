import Foundation
import UIKit

protocol CreateTrackerControllerNavigationDelegate: AnyObject {
    func startHabitsFlow()
    func showIrregularEvent(delegate: IrregularEventControllerDelegate?)
}

final class CreateTrackerCoordinator: BaseCoordinator {
    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    
    weak var delegate: CreateTrackerControllerDelegate?
    weak var context: CreateTrackerController?
    
    init(navigationController: UINavigationController,
         dependencies: CoordinatorDependencies,
         screenFactory: ScreenFactory) {
        
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 CreateTrackerCoordinator.start() вызван. delegate = \(String(describing: delegate))")
        
        let createTrackerVC = screenFactory.makeCreateTrackerScreen(delegate: self)
        context = createTrackerVC
        show(createTrackerVC)
    }
}

extension CreateTrackerCoordinator: CreateTrackerControllerDelegate {
    func startHabitsFlow() {
        print("🟢 Координатор CreateTrackerCoordinator: startHabitsFlow")

        let habitsCoordinator = HabitsControllerCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory
        )
        
        habitsCoordinator.createHabitsDelegate = context
        childCoordinators.append(habitsCoordinator)
        habitsCoordinator.start()
    }
    
    // Пока не реализовываем
    func showIrregularEvent(delegate: IrregularEventControllerDelegate?) {
        print("🟢 Координатор CreateTrackerCoordinator: showIrregularEvent")
    }
}

extension CreateTrackerCoordinator: CreateTrackerControllerNavigationDelegate {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) async {
        print("🟢 CreateTrackerCoordinator: Создан трекер \(tracker) в категории \(category)")
        await (navigationController.viewControllers.first as? TrackersViewController)?
                .didCreateTracker(tracker, inCategory: category)
       }
    
    // Пока не реализовываем
    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) async {
        print("")
    }
}
