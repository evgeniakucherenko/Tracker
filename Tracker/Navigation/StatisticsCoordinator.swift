import Foundation
import UIKit

final class StatisticsCoordinator: BaseCoordinator {
    private let statisticsService: StatisticsServiceProtocol

    init(navigationController: UINavigationController, statisticsService: StatisticsServiceProtocol) {
        self.statisticsService = statisticsService
        super.init(navigationController: navigationController)
    }

    override func start() {
        let viewModel = statisticsService.makeStatisticsViewModel()
        let statisticsVC = StatViewController(viewModel: viewModel)
        statisticsVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics", comment: ""),
            image: UIImage(named: "stats_icon"),
            tag: 1
        )

        navigationController.viewControllers = [statisticsVC]
    }
}
