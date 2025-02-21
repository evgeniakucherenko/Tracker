import UIKit

final class HabitsController: BaseCreateTrackerController<HabitsViewModel>,
                                    ScheduleViewControllerDelegate,
                                    CategorySelectionDelegate {

    weak var createHabitsDelegate: CreateHabitsControllerDelegate?

    private lazy var categoryButton: CustomSelectionButton = {
        let category = NSLocalizedString("category", comment: "")
        let button = CustomSelectionButton(title: category)
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var scheduleButton: CustomSelectionButton = {
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

    init(categoryStore: TrackerCategoryStoreProtocol) {
        let viewModel = HabitsViewModel(categoryStore: categoryStore)
        super.init(viewModel: viewModel)
    }

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

    override func bindBaseViewModel() {
        super.bindBaseViewModel()

        viewModel.onCategoryButtonSubtitleChanged = { [weak self] subtitle in
            guard let self = self else { return }
            self.categoryButton.update(title: "Категория", subtitle: subtitle)
        }

        viewModel.onScheduleButtonSubtitleChanged = { [weak self] subtitle in
            guard let self = self else { return }
            if let subtitle = subtitle, !subtitle.isEmpty {
                self.scheduleButton.update(title: "Расписание", subtitle: subtitle)
            } else {
                self.scheduleButton.update(title: "Расписание")
            }
        }
    }

    override func handleCreateTracker(tracker: Tracker, category: String) {
        createHabitsDelegate?.didCreateTracker(tracker, inCategory: category)
        closeModalAndSwitchToTab(index: 0)
    }

    @objc private func categoryButtonTapped() {
        let categoryViewModel = CategoryViewModel(categoryStore: viewModel.categoryStoreRef)
        let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
        categoryViewController.delegate = self

        let navController = UINavigationController(rootViewController: categoryViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }

    @objc private func scheduleButtonTapped() {
        let selectedDays = Set<Weekday>()
        let scheduleViewModel = ScheduleViewModel(initialSelectedDays: selectedDays)
        let scheduleViewController = ScheduleViewController(viewModel: scheduleViewModel)
        scheduleViewController.scheduleDelegate = self
        let navController = UINavigationController(rootViewController: scheduleViewController)
        present(navController, animated: true, completion: nil)
    }

    func didSelectCategory(_ categoryName: String) {
        viewModel.selectCategory(categoryName)
    }

    func didSelect(days: Set<Weekday>) {
        viewModel.updateSelectedDays(days)
    }
}
