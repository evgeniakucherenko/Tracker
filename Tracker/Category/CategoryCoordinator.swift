import UIKit

final class CategoryCoordinator: BaseCoordinator {
    
    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    var onCategorySelected: ((String) -> Void)? 

    init(
        navigationController: UINavigationController,
        dependencies: CoordinatorDependencies,
        screenFactory: ScreenFactory,
        onCategorySelected: @escaping (String) -> Void
    ) {
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        self.onCategorySelected = onCategorySelected
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = CategoryViewModel(categoryStore: dependencies.categoryStore)
        
        let categoryVC = screenFactory.makeCategoryScreen(
            viewModel: viewModel,
            onCategorySelected: { [weak self] category in
                print("📌 Выбрана категория: \(category)")
                self?.onCategorySelected?(category) // Передаем категорию обратно
                self?.goBack()
            },
            onAddCategoryTapped: { [weak self] in
                self?.showCreateCategory()
            },
            onCategoryCreated: { [weak self] newCategory in
                Task {
                    await viewModel.addCategory(newCategory)
                    await viewModel.fetchCategories()
                }
            }
        )

        categoryVC.coordinator = self
        show(categoryVC)
    }
    
    private func showCreateCategory() {
        let createCategoryCoordinator = CreateCategoryCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory
        )

        createCategoryCoordinator.onCategoryCreated = { [weak self] newCategory in
            print("🟢 Новая категория создана: \(newCategory)")
            self?.goBack()
        }

        childCoordinators.append(createCategoryCoordinator)
        createCategoryCoordinator.start()
    }

    private func goBack() {
        if let navController = getTopNavigationController(), navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss()
        }
    }

    private func dismiss() {
        getTopNavigationController()?.dismiss(animated: true)
    }
}
