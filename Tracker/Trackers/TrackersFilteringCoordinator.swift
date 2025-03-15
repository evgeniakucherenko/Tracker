import Foundation
import UIKit

final class TrackersFilteringCoordinator: BaseCoordinator {
    weak var delegate: TrackersFilteringCoordinatorDelegate? // объект, который получит результат выбора фильтра
    
    override func start() {
        print("🟢 TrackersFilteringCoordinator запущен")
        let filteringController = TrackersFilteringController()
        filteringController.delegate = self
        navigationController.present(filteringController, animated: true)
    }
}

// MARK: - TrackersFilteringControllerDelegate
extension TrackersFilteringCoordinator: TrackersFilteringControllerDelegate {
    func didSelectFilter(at index: Int) {
        print("🟢 TrackersFilteringCoordinator передаёт фильтр:", index)
        delegate?.didSelectFilter(at: index)

        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let index = (self.delegate as? BaseCoordinator)?.childCoordinators.firstIndex(where: { $0 === self }) {
                (self.delegate as? BaseCoordinator)?.childCoordinators.remove(at: index)
            }
        }
    }
}
