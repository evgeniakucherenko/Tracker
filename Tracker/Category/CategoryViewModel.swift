
import UIKit

final class CategoryViewModel {
    private var categoryStore: TrackerCategoryStoreProtocol
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }

    var onCategoriesUpdated: Binding<[TrackerCategory]>?
    var onError: Binding<String>?

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
    }
    
    func fetchCategories() {
        do {
            self.categories = try categoryStore.fetchAllCategories()
        } catch {
            onError?("Ошибка при получении категорий: \(error.localizedDescription)")
        }
    }

    func addCategory(_ categoryName: String) {
        do {
            let newCategory = TrackerCategory(title: categoryName, trackers: [])
            try categoryStore.addCategory(newCategory)
            fetchCategories()
        } catch {
            onError?("Ошибка при добавлении категории: \(error)")
        }
    }

    func deleteCategory(at index: Int) {
        let category = categories[index]
        do {
            try categoryStore.deleteCategory(category)
            fetchCategories()
        } catch {
            onError?("Ошибка при удалении категории: \(error)")
        }
    }
    
    func updateCategory(_ category: TrackerCategory, with newTitle: String) {
        do {
            try categoryStore.renameCategory(from: category, to: newTitle)
            fetchCategories()
        } catch {
            onError?("Ошибка при редактировании категории: \(error.localizedDescription)")
        }
    }
}
