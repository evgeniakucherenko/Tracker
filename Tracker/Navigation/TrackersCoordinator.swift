import Foundation
import UIKit

final class TrackersCoordinator: Coordinator {

    var navigationController: UINavigationController
    private var categoryCoordinator: CategoryCoordinator?
    private var createTrackerController: CreateTrackerController?
    private var habitsController: HabitsController?
    
    private let trackerStore: TrackerStoreProtocol
    private let categoryStore: TrackerCategoryStoreProtocol
    
    init(
        navigationController: UINavigationController,
        trackerStore: TrackerStoreProtocol,
        categoryStore: TrackerCategoryStoreProtocol
    ) {
        self.navigationController = navigationController
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
    }
    
    func start() {
        let viewModel = TrackersViewModel(
            trackerStore: trackerStore,
            categoryStore: categoryStore
        )
        let viewController = TrackersViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: false)
    }

    // MARK: - Переходы
    func showCreateTracker(delegate: CreateTrackerControllerDelegate) {
        let controller = CreateTrackerController(categoryStore: categoryStore)
        controller.delegate = delegate
        controller.coordinator = self
        
        self.createTrackerController = controller
        
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        navigationController.present(navController, animated: true)
    }

    func showEditTrackerScreen(for tracker: Tracker, categoryStore: TrackerCategoryStoreProtocol, trackerStore: TrackerStoreProtocol) {
        let viewModel = EditTrackerViewModel(
            tracker: tracker,
            categoryStore: categoryStore,
            trackerStore: trackerStore
        )
        
        let editController = EditTrackerController(viewModel: viewModel)
        navigationController.pushViewController(editController, animated: true)
    }

    func showFilterScreen(delegate: TrackersFilteringControllerDelegate) {
        let filtersViewController = TrackersFilteringController()
        filtersViewController.delegate = delegate

        let navController = UINavigationController(rootViewController: filtersViewController)
        navController.modalPresentationStyle = .formSheet

        navigationController.present(navController, animated: true)
    }
    
    private func showCategoryScreenAfterDismiss(delegate: CategorySelectionDelegate) {
        let categoryCoordinator = CategoryCoordinator(
            navigationController: navigationController,
            categoryStore: categoryStore
        )
        self.categoryCoordinator = categoryCoordinator
        categoryCoordinator.start(delegate: delegate)
    }
    
    func showCreateHabits(delegate: CreateHabitsControllerDelegate?) {
        let controller = HabitsController(categoryStore: categoryStore)
        controller.coordinator = self
        controller.createHabitsDelegate = delegate
        
        self.habitsController = controller
        
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .formSheet
        
        if let topController = navigationController.presentedViewController {
            topController.present(navController, animated: true)
        } else {
            print("🔴 Ошибка: Не удалось получить presentedViewController")
        }
    }
    
   
    func showCategoryScreen(delegate: CategorySelectionDelegate) {
        let categoryCoordinator = CategoryCoordinator(
            navigationController: navigationController,
            categoryStore: categoryStore
        )
        
        self.categoryCoordinator = categoryCoordinator
        categoryCoordinator.start(delegate: delegate)
    }
}
