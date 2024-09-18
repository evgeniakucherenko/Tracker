//
//  TabBarController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 26.08.2024.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tabBar.isTranslucent = false

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trackerRecordStore = TrackerRecordStore(context: context)
        let trackerStore = TrackerStore(context: context, trackerRecordStore: trackerRecordStore)
        let categoryStore = TrackerCategoryStore(context: context)

        let trackerViewController = TrackersViewController(trackerStore: trackerStore, categoryStore: categoryStore)
        let statisticsViewController = StatViewController()
        
        let navigationController = UINavigationController(rootViewController: trackerViewController)

        trackerViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "trackers_icon"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "stats_icon"), tag: 1)

        self.viewControllers = [navigationController, statisticsViewController]
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
