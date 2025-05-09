import UIKit

final class HabitsController: BaseCreateTrackerController<HabitsViewModel> {
    
    weak var navigationDelegate: HabitsNavigationDelegate?
    weak var createHabitsDelegate: CreateHabitsControllerDelegate?
    
    lazy var categoryButton: CustomSelectionButton = {
        let category = NSLocalizedString("category", comment: "")
        let button = CustomSelectionButton(title: category)
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var scheduleButton: CustomSelectionButton = {
        let schedule = NSLocalizedString("schedule", comment: "")
        let button = CustomSelectionButton(title: schedule)
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        button.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        return button
    }()

    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .grayColorYP)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(viewModel: HabitsViewModel) {
        super.init(viewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupNavBar() {
        let newHabit = NSLocalizedString("newHabit", comment: "")
        _ = TitlePopup(title: newHabit, navigationItem: navigationItem)
    }

    override func setupViews() {
        super.setupViews()
        [categoryButton, scheduleButton, separatorLine].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.deactivate([emojiCollectionView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 200)])

        categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8)

        NSLayoutConstraint.activate([
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryButtonTopConstraint!,
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            scheduleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scheduleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),

            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            separatorLine.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),

            emojiCollectionView.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 32)
        ])
    }

    override func handleCreateTracker(tracker: Tracker, category: String) {
        Task {
            print("🟢 HabitsController: Создаем трекер \(tracker), категория: \(category)")
            await createHabitsDelegate?.didCreateTracker(tracker, inCategory: category)
            closeModalAndSwitchToTab(index: 0)
        }
    }
     
    @objc private func categoryButtonTapped() {
        navigationDelegate?.showCategoryScreen()
    }
    
    @objc private func scheduleButtonTapped() {
        navigationDelegate?.showScheduleScreen(currentlySelectedDays: viewModel.selectedDays)
    }

    func didSelectCategory(_ categoryName: String) {
        print("🟢 HabitsController: выбрана категория \(categoryName)")
        viewModel.selectCategory(categoryName)
        categoryButton.update(title: "Категория", subtitle: categoryName)
    }
    
    func updateSelectedSchedule(days: Set<Weekday>) {
        print("🟢 HabitsController: обновляем расписание \(days)")

        viewModel.selectedDays = days  
        let formattedDays = days.map { $0.shortName }.joined(separator: ", ")

        DispatchQueue.main.async { [weak self] in
            self?.scheduleButton.update(title: "Расписание", subtitle: formattedDays)
        }
    }
}
