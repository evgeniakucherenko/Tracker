import Foundation

class CreateCategoryViewModel {
    
    private(set) var isValid: Bool = false {
        didSet {
            onValidationChange?(isValid)
        }
    }
    
    var onValidationChange: Binding<Bool>?
    
    func updateCategoryName(_ name: String?) {
        isValid = !(name?.isEmpty ?? true)
    }
    
    func createCategory(named name: String) -> TrackerCategory {
        return TrackerCategory(title: name, trackers: [])
    }
}
