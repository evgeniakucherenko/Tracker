import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

class BaseCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        assertionFailure("Subclasses must override start()")
    }

    func show(_ viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let topNavController = self.getTopNavigationController() else {
                print("❌ Не удалось получить topNavController")
                return
            }

            let modalController = viewController as? UINavigationController ?? UINavigationController(rootViewController: viewController)
            
            modalController.modalPresentationStyle = .formSheet

            if topNavController.presentedViewController != nil {
                print("⚠️ Уже есть модальный экран, сначала закрываем его")
                topNavController.dismiss(animated: true) {
                    topNavController.present(modalController, animated: true)
                }
            } else {
                topNavController.present(modalController, animated: true)
            }
        }
    }
    
    func getTopNavigationController() -> UINavigationController? {
        var topController: UIViewController? = navigationController

        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }

        return topController as? UINavigationController ?? topController?.navigationController
    }
}
