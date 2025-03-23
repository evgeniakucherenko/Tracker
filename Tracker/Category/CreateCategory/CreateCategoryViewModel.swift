import Foundation

final class CreateCategoryViewModel {
    
    var coordinator: CreateCategoryCoordinator?
    var onValidationChange: Binding<Bool>?
    let editableCategory: TrackerCategory?
    
    private(set) var isValid: Bool = false {
        didSet {
            onValidationChange?(isValid)
        }
    }
    
    init(editableCategory: TrackerCategory? = nil) {
        self.editableCategory = editableCategory
    }
    
    func updateCategoryName(_ name: String?) {
        isValid = !(name?.isEmpty ?? true)
        coordinator?.updateDoneButtonState(isValid)
    }
    
    func createOrUpdateCategory(_ name: String) {
        guard !name.isEmpty else { return }
            
        if editableCategory != nil {
            coordinator?.didUpdateCategory(newTitle: name)
        } else {
            coordinator?.didCreateCategory(name: name)
        }
    }

    func getCategoryName(for name: String) -> String {
        return name
    }
}
