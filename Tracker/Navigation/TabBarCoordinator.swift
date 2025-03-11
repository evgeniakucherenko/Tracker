import Foundation
import UIKit

final class TabBarCoordinator: Coordinator {

    var navigationController: UINavigationController
    private var trackersCoordinator: TrackersCoordinator?

    private let trackerStore: TrackerStoreProtocol
    private let categoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol

    init(
        trackerStore: TrackerStoreProtocol,
        categoryStore: TrackerCategoryStoreProtocol,
        trackerRecordStore: TrackerRecordStoreProtocol
    ) {
        self.navigationController = UINavigationController()
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.trackerRecordStore = trackerRecordStore
    }

    func start() {
        let tabBarController = CustomTabBarController()

        let trackersCoord = TrackersCoordinator(
            navigationController: UINavigationController(),
            trackerStore: trackerStore,
            categoryStore: categoryStore
        )

        trackersCoord.start()

        self.trackersCoordinator = trackersCoord

        let statisticsViewModel = StatViewModel(
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore
        )
        let statisticsVC = StatViewController(viewModel: statisticsViewModel)
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)

        let nameTabBarTrackers = NSLocalizedString("trackers", comment: "")
        let nameTabBarStatistics = NSLocalizedString("statistics", comment: "")

        trackersCoord.navigationController.tabBarItem = UITabBarItem(
            title: nameTabBarTrackers,
            image: UIImage(named: "trackers_icon"),
            tag: 0
        )
        statisticsNav.tabBarItem = UITabBarItem(
            title: nameTabBarStatistics,
            image: UIImage(named: "stats_icon"),
            tag: 1
        )

        tabBarController.viewControllers = [
            trackersCoord.navigationController,
            statisticsNav
        ]

        navigationController.setViewControllers([tabBarController], animated: false)
    }
}
