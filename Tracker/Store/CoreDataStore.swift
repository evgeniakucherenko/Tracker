import CoreData

class CoreDataStore: NSObject, NSFetchedResultsControllerDelegate {
    // MARK: - Properties
    private var onChangeCallback: (() -> Void)?
    
    // MARK: - Public Methods
    func subscribeToChanges(_ onChange: @escaping () -> Void) {
        self.onChangeCallback = onChange
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyChanges()
    }
    
    // MARK: - Private Methods
    func notifyChanges() {
        onChangeCallback?()
    }
}
