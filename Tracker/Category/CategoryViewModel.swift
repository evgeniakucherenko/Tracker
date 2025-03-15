
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
    
    func fetchCategories() async {
        do {
            self.categories = try await categoryStore.fetchAllCategories()
        } catch {
            onError?("Ошибка при получении категорий: \(error.localizedDescription)")
        }
    }

    func addCategory(_ categoryName: String) async {
        do {
            let newCategory = TrackerCategory(title: categoryName, trackers: [])
            try await categoryStore.addCategory(newCategory)
            await fetchCategories()
        } catch {
            onError?("Ошибка при добавлении категории: \(error.localizedDescription)")
        }
    }
    
    func deleteCategory(at index: Int) async {
        let category = categories[index]
        do {
            try await categoryStore.deleteCategory(category)
            await fetchCategories()
        } catch {
            onError?("Ошибка при удалении категории: \(error)")
        }
    }

    func updateCategory(_ category: TrackerCategory, with newTitle: String) async {
        do {
            try await categoryStore.renameCategory(from: category, to: newTitle)
            await fetchCategories()
        } catch {
            onError?("Ошибка при редактировании категории: \(error.localizedDescription)")
        }
    }
}
