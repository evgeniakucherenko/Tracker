import Foundation
import UIKit

// Билдер для координаторов + контейнер зависимостей

final class CoordinatorBuilder<T: BaseCoordinator> {
    private var initializer: ((UINavigationController, CoordinatorDependencies) -> T)?
    private var setupBlock: ((T) -> Void)?
    private let dependencies: CoordinatorDependencies

    init(dependencies: CoordinatorDependencies) {
        self.dependencies = dependencies
    }

    func setInitializer(_ initializer: @escaping (UINavigationController, CoordinatorDependencies) -> T) -> Self {
        self.initializer = initializer
        return self
    }

    func setup(_ block: @escaping (T) -> Void) -> Self {
        self.setupBlock = block
        return self
    }
    
    func build(navigationController: UINavigationController) -> T {
        guard let initializer = initializer else {
            fatalError("Initializer for \(T.self) is not set.")
        }
        let coordinator = initializer(navigationController, dependencies)
        setupBlock?(coordinator)
        return coordinator
    }
}

final class CoordinatorDependencies {
    let trackerStore: TrackerStoreProtocol
    let categoryStore: TrackerCategoryStoreProtocol
    let trackerRecordStore: TrackerRecordStoreProtocol

    init(trackerStore: TrackerStoreProtocol, categoryStore: TrackerCategoryStoreProtocol,trackerRecordStore: TrackerRecordStoreProtocol) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        self.trackerRecordStore = trackerRecordStore
    }
}
