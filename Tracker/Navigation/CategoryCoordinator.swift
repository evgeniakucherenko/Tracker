import UIKit

final class CategoryCoordinator: Coordinator {
    
    var navigationController: UINavigationController
    private let categoryStore: TrackerCategoryStoreProtocol
    
    init(navigationController: UINavigationController, categoryStore: TrackerCategoryStoreProtocol) {
        self.navigationController = navigationController
        self.categoryStore = categoryStore
    }
    
    func start() {
        start(delegate: nil)
    }
    
    func start(delegate: CategorySelectionDelegate?) {

        let viewModel = CategoryViewModel(categoryStore: categoryStore)
        let categoryViewController = CategoryViewController(viewModel: viewModel)
        categoryViewController.coordinator = self
        categoryViewController.delegate = delegate
        
        let navController = UINavigationController(rootViewController: categoryViewController)
        
        navController.modalPresentationStyle = .fullScreen
        
        if let topController = getTopViewController() {
            topController.present(navController, animated: true)
        } else {
            print("🔴 Ошибка: Не удалось получить topViewController")
        }
    }
    
    func showCreateCategory(onCategoryCreated: @escaping (TrackerCategory) -> Void) {
        let viewModel = CreateCategoryViewModel()
        let createCategoryController = CreateCategoryViewController(viewModel: viewModel)
        
        createCategoryController.onCategoryCreated = onCategoryCreated
        
        let navController = UINavigationController(rootViewController: createCategoryController)
        navController.modalPresentationStyle = .fullScreen
        
        if let topController = getTopViewController() {
            topController.present(navController, animated: true)
        } else {
            print("🔴 Ошибка: Не удалось получить topViewController")
        }
    }
    
    func getTopViewController() -> UIViewController? {
        var topController: UIViewController? = navigationController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
}
