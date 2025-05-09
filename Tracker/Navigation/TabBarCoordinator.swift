import Foundation
import UIKit

final class TabBarCoordinator: BaseCoordinator {
    private var trackersCoordinator: TrackersCoordinator?
    private var statisticsCoordinator: StatisticsCoordinator?
    private let dependencies: CoordinatorDependencies
    private let statisticsService: StatisticsServiceProtocol
    private let screenFactory: ScreenFactory

    init(navigationController: UINavigationController, dependencies: CoordinatorDependencies) {
        self.dependencies = dependencies
        self.statisticsService = StatisticsService(
            trackerStore: dependencies.trackerStore,
            trackerRecordStore: dependencies.trackerRecordStore
        )

        self.screenFactory = ScreenFactory(dependencies: dependencies)
        super.init(navigationController: navigationController)
    }

    override func start() {
        let tabBarController = CustomTabBarController()
        
        let screenFactory = ScreenFactory(dependencies: dependencies)

        let trackersCoord = CoordinatorBuilder<TrackersCoordinator>(dependencies: dependencies)
            .setInitializer { TrackersCoordinator(navigationController: $0, dependencies: $1, screenFactory: screenFactory) } // ✅ Передаём объект
            .build(navigationController: UINavigationController())

        trackersCoord.start()
        childCoordinators.append(trackersCoord)

        let statisticsCoord = StatisticsCoordinator(
            navigationController: UINavigationController(),
            statisticsService: statisticsService // <-- Передаём сервис, а не ViewModel
        )

        statisticsCoord.start()
        childCoordinators.append(statisticsCoord)

        let nameTabBarTrackers = NSLocalizedString("trackers", comment: "")

        trackersCoord.navigationController.tabBarItem = UITabBarItem(
            title: nameTabBarTrackers,
            image: UIImage(named: "trackers_icon"),
            tag: 0
        )

        tabBarController.viewControllers = [
            trackersCoord.navigationController,
            statisticsCoord.navigationController 
        ]

        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
