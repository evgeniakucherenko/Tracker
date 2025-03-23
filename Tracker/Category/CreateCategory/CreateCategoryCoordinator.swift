import Foundation
import UIKit

final class CreateCategoryCoordinator: BaseCoordinator {
    
    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    
    private var context: CreateCategoryViewController?
    weak var categoryController: CategoryViewController?
    
    var editableCategory: TrackerCategory?

    init(navigationController: UINavigationController,
        dependencies: CoordinatorDependencies,
        screenFactory: ScreenFactory) {
            
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 `CreateCategoryCoordinator.start()` вызван")

        let createCategoryVC = screenFactory.makeCreateCategoryScreen(
            editableCategory: editableCategory,
            coordinator: self
        )
        
        context = createCategoryVC
        show(createCategoryVC)
    }
    
    func updateDoneButtonState(_ isEnabled: Bool) {
        context?.updateDoneButtonState(isEnabled)
    }
    
    func didCreateCategory(name: String) {
        print("🟢 `CreateCategoryCoordinator`: создана категория `\(name)`, передаем в ViewModel")

        Task {
            await categoryController?.viewModel.addCategory(name)
        }
        
        closeCreateCategoryScreen()
    }
    
    func didUpdateCategory(newTitle: String) {
        guard let oldCat = editableCategory else { return }
        print("🟢 `CreateCategoryCoordinator`: обновляем категорию `\(oldCat.title)` на `\(newTitle)`")

        Task {
            await categoryController?.viewModel.updateCategory(oldCat, with: newTitle)
        }
        
        closeCreateCategoryScreen()
    }

    func closeCreateCategoryScreen() {
        context?.dismiss(animated: true)
    }
}
