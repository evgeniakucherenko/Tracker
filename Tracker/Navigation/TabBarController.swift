import Foundation
import UIKit

final class TabBarController: UITabBarController {

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        tabBar.isTranslucent = false
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Не удалось получить делегат приложения.")
            return
        }

        let context = appDelegate.persistentContainer.viewContext
        let trackerRecordStore = TrackerRecordStore(context: context)
        let trackerStore = TrackerStore(context: context, trackerRecordStore: trackerRecordStore)
        let categoryStore = TrackerCategoryStore(context: context)

        let trackerViewController = TrackersViewController(trackerStore: trackerStore, categoryStore: categoryStore)
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        
        let statisticsViewController = StatViewController(
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore
        )
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        let nameTabBarTrackers = NSLocalizedString("trackers", comment: "")
        let nameTabBarStatistics = NSLocalizedString("statistics", comment: "")
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: nameTabBarTrackers,
            image: UIImage(named: "trackers_icon"),
            tag: 0
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: nameTabBarStatistics,
            image: UIImage(named: "stats_icon"),
            tag: 1
        )

        self.viewControllers = [trackerNavigationController, statisticsNavigationController]
        self.addTopBorder(color: UIColor.gray, thickness: 0.5)
    }
}

extension TabBarController {
    private func addTopBorder(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: thickness)
        tabBar.layer.addSublayer(border)
    }
}
