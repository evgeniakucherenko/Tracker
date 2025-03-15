import Foundation

final class CreateCategoryViewModel {
    private(set) var isValid: Bool = false {
        didSet {
            onValidationChange?(isValid)
        }
    }
    //weak var delegate: CreateCategoryViewModelDelegate?

    var onValidationChange: Binding<Bool>?
    private let editableCategory: TrackerCategory?

    init(editableCategory: TrackerCategory? = nil) {
        self.editableCategory = editableCategory
    }
    
    func updateCategoryName(_ name: String?) {
        isValid = !(name?.isEmpty ?? true)
    }
    
    func getCategoryName(for name: String) -> String {
        return name
    }
    
    func createCategory(_ name: String) {
        guard !name.isEmpty else { return }

        let newCategory = TrackerCategory(title: name, trackers: [])
        //delegate?.didCreateCategory(newCategory)
    }
}
