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
    
    func show(_ viewController: UIViewController, asModal: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let topNavController = self.getTopNavigationController() else { return }

            if asModal {
                let modalController = viewController as? UINavigationController ?? UINavigationController(rootViewController: viewController)
                modalController.modalPresentationStyle = .fullScreen
                topNavController.present(modalController, animated: true)
            } else if !(viewController is UINavigationController) {
                topNavController.pushViewController(viewController, animated: true)
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
