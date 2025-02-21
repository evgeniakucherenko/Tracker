
import UIKit

final class AlertPresenter {
    
    // MARK: - Properties
    private weak var viewController: UIViewController?
    
    // MARK: - Initialization
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Confirmation Alert
    func presentConfirmationAlert(
        message: String,
        destructiveTitle: String,
        destructiveHandler: @escaping () -> Void,
        cancelTitle: String = NSLocalizedString("cancel", comment: "Отменить")
    ) {
        let alertController = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: destructiveTitle,
            style: .destructive
        ) { _ in
            destructiveHandler()
        }
        
        let cancelAction = UIAlertAction(
            title: cancelTitle,
            style: .cancel,
            handler: nil
        )
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        viewController?.present(alertController, animated: true, completion: nil)
    }
}
