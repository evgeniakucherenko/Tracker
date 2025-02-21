import UIKit

class BaseCreateTrackerViewModel {
    var trackerName: String = ""
    var selectedCategory: String?
    var selectedEmoji: String?
    var selectedColor: UIColor?

    var onCreateButtonStateChanged: ((Bool) -> Void)?
    var onErrorLabelVisibilityChanged: ((Bool) -> Void)?
    var onCategoryButtonSubtitleChanged: ((String?) -> Void)?

    func updateTrackerName(_ name: String) {
        trackerName = name
        validateForm()
    }

    func validateNameLength(_ name: String) -> Bool {
        return name.count <= 38
    }

    func selectCategory(_ categoryName: String) {
        selectedCategory = categoryName
        onCategoryButtonSubtitleChanged?(categoryName)
        validateForm()
    }

    func selectEmoji(_ emoji: String) {
        selectedEmoji = emoji
        validateForm()
    }

    func selectColor(_ color: UIColor) {
        selectedColor = color
        validateForm()
    }

    func validateForm() {
        let isNameFilled = !trackerName.isEmpty
        let isCategorySelected = selectedCategory != nil
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil

        let isFormValid = isNameFilled && isCategorySelected && isEmojiSelected && isColorSelected
        onCreateButtonStateChanged?(isFormValid)
    }

    func createTracker() -> (Tracker, String)? {
        guard !trackerName.isEmpty,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor else {
            return nil
        }

        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: [], // по умолчанию пустой
            isPinned: false
        )

        return (tracker, selectedCategory ?? "Без категории")
    }
    
    func showError(_ show: Bool) {
        onErrorLabelVisibilityChanged?(show)
    }
}
