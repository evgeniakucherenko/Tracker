import UIKit

final class CategoryCoordinator: BaseCoordinator {

    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory

    private var context: CategoryViewController?
    weak var habitsController: HabitsController?
    
    init(
        navigationController: UINavigationController,
        dependencies: CoordinatorDependencies,
        screenFactory: ScreenFactory
    ) {
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 CategoryCoordinator: start() вызван")

        let categoryVC = screenFactory.makeCategoryScreen(coordinator: self)
        context = categoryVC
        show(categoryVC)
    }
    
    // Методы, которые будет вызывать ViewModel
    func updateCategoryScreen(with categories: [TrackerCategory]) {
        context?.updateTableView(with: categories)
    }

    func didSelectCategory(_ categoryName: String) {
        print("🟢 CategoryCoordinator: didSelectCategory = \(categoryName)")
        habitsController?.didSelectCategory(categoryName)
        closeCategoryScreen()
    }
    
    func closeCategoryScreen() {
        context?.dismiss(animated: true)
    }
    
    func showCreateCategory() {
        print("🟢 CategoryCoordinator: showCreateCategory() called")
        let createCategoryCoordinator = CreateCategoryCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory
        )

        createCategoryCoordinator.categoryController = context
        childCoordinators.append(createCategoryCoordinator)
        createCategoryCoordinator.start()
    }
    
    func showEditCategory(for category: TrackerCategory) {
        print("🟢 CategoryCoordinator: showEditCategory(for: \(category.title))")

        let editCategoryCoordinator = CreateCategoryCoordinator(
            navigationController: navigationController,
            dependencies: dependencies,
            screenFactory: screenFactory
        )
        
        editCategoryCoordinator.categoryController = context
        editCategoryCoordinator.editableCategory = category
        childCoordinators.append(editCategoryCoordinator)
        editCategoryCoordinator.start()
    }

    func handleError(_ error: Error) {
        print("🛑 CategoryCoordinator: ошибка — \(error.localizedDescription)")
        showErrorAlert(error.localizedDescription)
    }
}

extension CategoryCoordinator {
    
    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        context?.present(alert, animated: true)
    }
    
    func didTapDeleteCategory(_ category: TrackerCategory) {
        print("🟢 CategoryCoordinator: didTapDeleteCategory(\(category.title))")

        let alert = UIAlertController(
            title: "Удалить категорию?",
            message: "Вы уверены, что хотите удалить «\(category.title)»?\nЭто действие нельзя отменить.",
            preferredStyle: .alert
        )

        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            print("🟢 CategoryCoordinator: подтверждено удаление \(category.title)")

            Task {
                await self.context?.viewModel.deleteCategory(category)
            }
        }


        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        context?.present(alert, animated: true)
    }
}

