import Foundation
import UIKit

final class TrackersCoordinator: BaseCoordinator, TrackersViewControllerDelegate {
    
    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    private weak var delegate: TrackersViewControllerDelegate?
    private weak var filteringCoordinator: TrackersFilteringCoordinator?
    private var context: TrackersViewController?
   
    init(navigationController: UINavigationController,
         dependencies: CoordinatorDependencies,
         screenFactory: ScreenFactory) {
        
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 TrackersCoordinator подключился")

        let viewController = screenFactory.makeTrackersScreen(delegate: self, coordinator: self)
        
        context = viewController
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        context?.present(alert, animated: true, completion: nil)
    }
    
    func reloadTrackersScreen() {
        DispatchQueue.main.async {
            print("🟢 TrackersCoordinator: обновление данных")
            self.context?.reloadScreen()
        }
    }
    
    // Открытие экрана создания трекера
    func showCreateTracker(delegate: CreateTrackerControllerDelegate) {
        print("🟢 TrackersCoordinator: showCreateTracker, delegate = \(String(describing: delegate))")

        let createTrackerCoordinator = CreateTrackerCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory
        )

        createTrackerCoordinator.delegate = delegate
        self.childCoordinators.append(createTrackerCoordinator)
        createTrackerCoordinator.start()
    }
}

protocol TrackersFilteringCoordinatorDelegate: AnyObject {
    func didSelectFilter(at index: Int)
}

extension TrackersCoordinator: TrackersFilteringCoordinatorDelegate {
    
    // Получение фильтра от пользователя
    func didSelectFilter(at index: Int) {
        print("🟢 TrackersCoordinator получил фильтр:", index)
        delegate?.didSelectFilter(at: index)
    }
    
    // Открытие экрана фильтрации
    func showFilterScreen(delegate: TrackersFilteringCoordinatorDelegate) {
        let filteringCoordinator = TrackersFilteringCoordinator(navigationController: navigationController)
        filteringCoordinator.delegate = delegate
        filteringCoordinator.start()

        childCoordinators.append(filteringCoordinator)
    }
}
