import UIKit

final class CategoryViewModel {
    
    private var categoryStore: TrackerCategoryStoreProtocol
    weak var coordinator: CategoryCoordinator?
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            coordinator?.updateCategoryScreen(with: categories)
        }
    }

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
    }
    
    func fetchCategories() async {
        do {
            categories = try await categoryStore.fetchAllCategories()
        } catch {
            coordinator?.handleError(CategoryError.failedToFetch)
        }
    }
    
    func addCategory(_ categoryName: String) async {
        do {
            let newCategory = TrackerCategory(title: categoryName, trackers: [])
            try await categoryStore.addCategory(newCategory)
            await fetchCategories()
        } catch {
            coordinator?.handleError(CategoryError.failedToAdd)
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) async {
        do {
            try await categoryStore.deleteCategory(category)
            await fetchCategories()
        } catch {
            coordinator?.handleError(CategoryError.failedToDelete)
        }
    }

    func updateCategory(_ category: TrackerCategory, with newTitle: String) async {
        do {
            try await categoryStore.renameCategory(from: category, to: newTitle)
            await fetchCategories()
        } catch {
            coordinator?.handleError(CategoryError.failedToUpdate)
        }
    }
    
    // Метод, который дергает контроллер при выборе ячейки
    func didSelectCategory(at index: Int) {
        guard index < categories.count else { return }

        let selectedCategory = categories[index]
        let categoryName = selectedCategory.title
        coordinator?.didSelectCategory(categoryName)
    }
}

extension CategoryViewModel: CategoryControllerDelegate {
    func didTapAddCategoryButton() {
        coordinator?.showCreateCategory()
    }
    
    func didSelectCategory(_ category: TrackerCategory) {
        coordinator?.didSelectCategory(category.title)
    }
    
    func didTapEditCategory(_ category: TrackerCategory) {
        coordinator?.showEditCategory(for: category)
    }
    
    func didTapDeleteCategory(_ category: TrackerCategory) {
        coordinator?.didTapDeleteCategory(category)
    }
}

enum CategoryError: LocalizedError {
    case failedToAdd
    case failedToDelete
    case failedToRename
    case failedToUpdate
    case failedToFetch
    
    var errorDescription: String? {
        switch self {
        case .failedToAdd:
            return "Не удалось добавить категорию. Попробуйте ещё раз."
        case .failedToDelete:
            return "Не удалось удалить категорию. Попробуйте позже."
        case .failedToRename:
            return "Не удалось переименовать категорию."
        case .failedToUpdate:
            return "Не удалось обновить категории."
        case .failedToFetch:
            return "Не удалось загрузить категории."
        }
    }
}
