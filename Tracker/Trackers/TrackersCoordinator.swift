import Foundation
import UIKit

// Этот класс отвечает за навигацию внутри экрана трекеров (TrackersViewController), а также за открытие экранов создания трекера (CreateTrackerCoordinator) и фильтрации (TrackersFilteringCoordinator)

final class TrackersCoordinator: BaseCoordinator, TrackersViewControllerDelegate {
    private let dependencies: CoordinatorDependencies // хранилище всех зависимостей
    private weak var delegate: TrackersViewControllerDelegate?
    private let screenFactory: ScreenFactory // отвечает за создание экранов
    weak var filteringCoordinator: TrackersFilteringCoordinator? //  хранит координатор фильтрации

    init(navigationController: UINavigationController,
         dependencies: CoordinatorDependencies,
         screenFactory: ScreenFactory) {
        
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 TrackersCoordinator подключился")

        let viewController = screenFactory.makeTrackersScreen(delegate: self)
        navigationController.pushViewController(viewController, animated: false)
    }
    
    // Открытие экрана создания трекера
    func showCreateTracker(delegate: CreateTrackerControllerDelegate) {
        print("🟢 TrackersCoordinator: showCreateTracker")

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
