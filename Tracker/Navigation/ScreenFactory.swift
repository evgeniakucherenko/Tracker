import Foundation
import UIKit

final class ScreenFactory {
    private let dependencies: CoordinatorDependencies
    
    init(dependencies: CoordinatorDependencies) {
        self.dependencies = dependencies
    }
    
    func makeTrackersScreen(delegate: TrackersViewControllerDelegate?, coordinator: Coordinator?) -> TrackersViewController {
        let viewModel = TrackersViewModel(
            trackerStore: dependencies.trackerStore,
            categoryStore: dependencies.categoryStore
        )
        viewModel.coordinator = coordinator as? TrackersCoordinator
        let viewController = TrackersViewController(viewModel: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
    func makeCreateTrackerScreen(delegate: CreateTrackerControllerDelegate) -> CreateTrackerController {
        let controller = CreateTrackerController(categoryStore: dependencies.categoryStore)
        controller.delegate = delegate
        
        controller.navigationDelegate = delegate as? CreateTrackerControllerNavigationDelegate
        return controller
    }
    
    func makeHabitsScreen(navigationDelegate: HabitsNavigationDelegate?) -> HabitsController {
        let viewModel = HabitsViewModel(categoryStore: dependencies.categoryStore)
        let controller = HabitsController(viewModel: viewModel)
        controller.navigationDelegate = navigationDelegate
        return controller
    }
    
    
    func makeCreateCategoryScreen(
        editableCategory: TrackerCategory?,
        coordinator: CreateCategoryCoordinator
    ) -> CreateCategoryViewController {
        let viewModel = CreateCategoryViewModel(editableCategory: editableCategory)
        viewModel.coordinator = coordinator
        let createCategoryVC = CreateCategoryViewController(viewModel: viewModel)
        return createCategoryVC
    }
    
    func makeCategoryScreen(coordinator: CategoryCoordinator) -> CategoryViewController {
        let viewModel = CategoryViewModel(categoryStore: dependencies.categoryStore)
        viewModel.coordinator = coordinator
        let categoryVC = CategoryViewController(viewModel: viewModel)
        categoryVC.delegate = viewModel
        return categoryVC
    }
    
    func makeScheduleScreen(
        selectedDays: Set<Weekday>,
        delegate: ScheduleViewControllerDelegate?,
        coordinator: ScheduleCoordinator
    ) -> ScheduleViewController {
        let viewModel = ScheduleViewModel(initialSelectedDays: selectedDays) 
        viewModel.coordinator = coordinator
        let scheduleVC = ScheduleViewController(viewModel: viewModel)
        scheduleVC.scheduleDelegate = delegate
        return scheduleVC
    }
}
