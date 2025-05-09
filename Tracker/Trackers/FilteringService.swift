import Foundation
import UIKit

protocol FilteringServiceProtocol {
    func startFiltering(from navigationController: UINavigationController, delegate: TrackersFilteringCoordinatorDelegate)
}

final class FilteringService: FilteringServiceProtocol {
    func startFiltering(from navigationController: UINavigationController, delegate: TrackersFilteringCoordinatorDelegate) {
        let filteringCoordinator = TrackersFilteringCoordinator(navigationController: navigationController)
        filteringCoordinator.delegate = delegate
        filteringCoordinator.start()
    }
}
