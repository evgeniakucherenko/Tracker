import Foundation
import UIKit

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(name: String)
}

final class CreateCategoryCoordinator: BaseCoordinator {
    
    var onCategoryCreated: ((String) -> Void)?
    
    private let dependencies: CoordinatorDependencies
    private let screenFactory: ScreenFactory
    weak var creationDelegate: CategoryCreationDelegate?
    
    private let editableCategory: TrackerCategory?

    init(navigationController: UINavigationController,
        dependencies: CoordinatorDependencies,
        screenFactory: ScreenFactory,
        editableCategory: TrackerCategory? = nil) {
            
        self.dependencies = dependencies
        self.screenFactory = screenFactory
        self.editableCategory = editableCategory
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        print("🟢 `CreateCategoryCoordinator.start()` вызван")

        let createCategoryVC = screenFactory.makeCreateCategoryScreen(editableCategory: nil)
        createCategoryVC.delegate = self

        let navController = UINavigationController(rootViewController: createCategoryVC)
        navController.modalPresentationStyle = .formSheet
        show(navController, asModal: true)
    }
       
    func didCreateCategory(name: String) {
        print("🟢 `CreateCategoryCoordinator`: создана категория `\(name)`, передаем в ViewModel")
        onCategoryCreated?(name)
        goBack()
    }

    private func goBack() {
        if let navController = getTopNavigationController(),
           navController.viewControllers.count > 1 {
            navController.popViewController(animated: true)
        } else {
            dismiss()
        }
    }

    func dismiss() {
        getTopNavigationController()?.dismiss(animated: true)
    }
}

extension CreateCategoryCoordinator: CreateCategoryViewControllerDelegate {}
