import Foundation
import UIKit

final class ScreenFactory {
    private let dependencies: CoordinatorDependencies
    
    init(dependencies: CoordinatorDependencies) {
        self.dependencies = dependencies
    }
    
    func makeTrackersScreen(delegate: TrackersViewControllerDelegate?) -> TrackersViewController {
        let viewModel = TrackersViewModel(
            trackerStore: dependencies.trackerStore,
            categoryStore: dependencies.categoryStore
        )
        let viewController = TrackersViewController(viewModel: viewModel)
        viewController.delegate = delegate
        return viewController
    }
    
    func makeCreateTrackerScreen(delegate: CreateTrackerControllerDelegate) -> CreateTrackerController {
        let controller = CreateTrackerController(categoryStore: dependencies.categoryStore)
        controller.delegate = delegate
        return controller
    }
    
    func makeHabitsScreen(navigationDelegate: HabitsNavigationDelegate?) -> HabitsController {
        let viewModel = HabitsViewModel(categoryStore: dependencies.categoryStore)
        let controller = HabitsController(viewModel: viewModel)
        controller.navigationDelegate = navigationDelegate
        return controller
    }
    
    func makeCreateCategoryScreen(editableCategory: TrackerCategory?) -> CreateCategoryViewController {
        let viewModel = CreateCategoryViewModel(editableCategory: editableCategory)
        return CreateCategoryViewController(viewModel: viewModel)
    }
    
    func makeCategoryScreen(
        viewModel: CategoryViewModel,
        onCategorySelected: @escaping (String) -> Void,
        onAddCategoryTapped: @escaping () -> Void,
        onCategoryCreated: @escaping (String) -> Void
    ) -> CategoryViewController {
        let categoryVC = CategoryViewController(viewModel: viewModel)
        categoryVC.onCategorySelected = onCategorySelected
        categoryVC.onAddCategoryTapped = onAddCategoryTapped
        categoryVC.onCategoryCreated = onCategoryCreated
        return categoryVC
    }
}
