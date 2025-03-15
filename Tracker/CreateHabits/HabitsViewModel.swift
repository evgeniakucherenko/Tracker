import UIKit

final class HabitsViewModel: BaseCreateTrackerViewModel {
    private var categoryStore: TrackerCategoryStoreProtocol
    var selectedDays: Set<Weekday> = []

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        super.init()
    }

    func updateSelectedDays(_ days: Set<Weekday>) {
        selectedDays = days
        let subtitle: String?
        if selectedDays.count == Weekday.allCases.count {
            subtitle = "Каждый день"
        } else {
            subtitle = days.map { $0.shortName }.joined(separator: ", ")
        }
        onScheduleButtonSubtitleChanged?(subtitle)
        validateForm()
    }

    var onScheduleButtonSubtitleChanged: ((String?) -> Void)?

    override func validateForm() {
        super.validateForm()

        let isScheduleSelected = !selectedDays.isEmpty
        let isNameFilled = !trackerName.isEmpty
        let isCategorySelected = selectedCategory != nil
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil

        let isFormValid = isNameFilled && isCategorySelected && isEmojiSelected && isColorSelected && isScheduleSelected
        onCreateButtonStateChanged?(isFormValid)
    }

    override func createTracker() -> (Tracker, String)? {
        guard !trackerName.isEmpty,
              let selectedEmoji = selectedEmoji,
              let selectedColor = selectedColor,
              let selectedCategory = selectedCategory else {
            return nil
        }

        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedDays,
            isPinned: false
        )

        return (tracker, selectedCategory)
    }

    var categoryStoreRef: TrackerCategoryStoreProtocol {
        return categoryStore
    }
}
