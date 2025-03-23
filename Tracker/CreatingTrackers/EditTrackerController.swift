
import Foundation
import UIKit

final class EditTrackerController: UIViewController {
    
    // MARK: - Properties
    private let tracker: Tracker
    private let viewModel: EditTrackerViewModel
    
    private let emojiCollectionView = EmojiCollectionView()
    private let colorsCollectionView = ColorsCollectionView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var categoryButtonTopConstraint: NSLayoutConstraint?

    private lazy var cancelButton: CustomActionButton = {
        CustomActionButton(
            title: NSLocalizedString("cancel", comment: ""),
            backgroundColor: .clear,
            titleColor: UIColor(named: "red_YP") ?? .red,
            borderColor: UIColor(named: "red_YP"),
            borderWidth: 1,
            action: #selector(cancelButtonTapped),
            target: self
        )
    }()
    
    private lazy var createButton: CustomActionButton = {
        let button = CustomActionButton(
            title: NSLocalizedString("create", comment: ""),
            backgroundColor: UIColor(named: "buttonDisabledColor") ?? .gray,
            action: #selector(createButtonTapped),
            target: self
        )
        
        Task {
            let hasChanges = await viewModel.hasChanges
            button.setEnabled(
                hasChanges,
                enabledColor: UIColor.systemBlue,
                disabledColor: .grayColorYP
            )
        }
        
        return button
    }()

    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField()
        let trackerNameTextField = NSLocalizedString("trackerNameTextField", comment: "")
        textField.placeholder = trackerNameTextField
        textField.autocapitalizationType = .words
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        let errorTextLabel = NSLocalizedString("errorTextLabel", comment: "")
        label.text = errorTextLabel
        label.textColor = .redYP
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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

    // MARK: - Initializer
    init(viewModel: EditTrackerViewModel) {
        self.tracker = viewModel.trackerModel
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        updateTheme()
        
        setupViews()
        setupScrollView()
        setupConstraints()
        
        setupInitialState()
        setupActions()
        
    }
    
    private func setupInitialState() {
        nameTextField.text = viewModel.name
        categoryButton.update(title: "Категория", subtitle: viewModel.selectedCategory)
        scheduleButton.update(title: "Расписание", subtitle: formatSchedule(viewModel.selectedSchedule))
        colorsCollectionView.setSelectedColor(viewModel.selectedColor)
        emojiCollectionView.setSelectedEmoji(viewModel.selectedEmoji)
    }
    
    private func setupActions() {
        nameTextField.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        
        colorsCollectionView.onColorSelected = { [weak self] selectedColor in
            self?.viewModel.selectedColor = selectedColor
            self?.validateInputs()
        }
        
        emojiCollectionView.onEmojiSelected = { [weak self] selectedEmoji in
            self?.viewModel.selectedEmoji = selectedEmoji
            self?.validateInputs()
        }
    }
    
    private func formatSchedule(_ days: Set<Weekday>) -> String {
        return days.map { $0.shortName }.joined(separator: ", ")
    }
    
    // MARK: - Setup Methods
    private func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = backgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    private func setupNavBar() {
        let editHabit = NSLocalizedString("editHabit", comment: "")
        _ = TitlePopup(title: editHabit, navigationItem: navigationItem)
    }
    
    private func setupViews() {
        [cancelButton, createButton, nameTextField,
         categoryButton, scheduleButton, separatorLine, errorLabel,
         emojiCollectionView, colorsCollectionView].forEach {
            contentView.addSubview($0)
        }
    }

    // MARK: - Theme Updates
    private func updateTheme() {
        view.backgroundColor = ColorPalette.backgroundColor
    }
    
    // MARK: - Actions
    @objc private func createButtonTapped() {
        Task {
            do {
                let updatedTracker = try await viewModel.saveChanges()
                closeModalAndSwitchToTab(index: 0)
            } catch {
                print("Ошибка при сохранении изменений трекера: \(error.localizedDescription)")
            }
        }
    }

    @objc private func cancelButtonTapped() {
        closeModalAndSwitchToTab(index: 0)
    }

    @objc private func categoryButtonTapped() {
        let categoryViewModel = CategoryViewModel(categoryStore: viewModel.categoryStoreRef)
        let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
        //categoryViewController.delegate = self
        let navController = UINavigationController(rootViewController: categoryViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true)
    }
    
    @objc private func scheduleButtonTapped() {
        
        print("")
//        let viewModel = ScheduleViewModel(initialSelectedDays: viewModel.selectedSchedule)
//        let scheduleViewController = ScheduleViewController(viewModel: viewModel)
//        scheduleViewController.scheduleDelegate = self
//        let navController = UINavigationController(rootViewController: scheduleViewController)
//        navController.modalPresentationStyle = .formSheet
//        present(navController, animated: true, completion: nil)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    private func closeModalAndSwitchToTab(index: Int) {
        guard let window = UIApplication.shared.windows.first else { return }

        if let tabBarController = window.rootViewController as? CustomTabBarController {
            tabBarController.selectedIndex = index
        }

        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
        
    private func validateInputs() {
        Task {
            let isValid = await viewModel.hasChanges
            createButton.isEnabled = isValid
            createButton.backgroundColor = isValid ? .systemBlue : .gray
        }
    }

    @objc private func nameTextFieldChanged() {
        viewModel.name = nameTextField.text ?? ""
        validateInputs()
    }
}

extension EditTrackerController: ScheduleViewControllerDelegate {
    func didSelect(days: Set<Weekday>) {
        viewModel.selectedSchedule = days
        scheduleButton.setTitle("\(days.count) дней выбрано", for: .normal)
        validateInputs()
    }
}

extension EditTrackerController {
    // MARK: - Layout
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupConstraints() {

        categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8)

        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 40),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),

            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 40),

            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),

            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            categoryButtonTopConstraint!,
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            scheduleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            scheduleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 0),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),

            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            separatorLine.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1),

            emojiCollectionView.topAnchor.constraint(equalTo: scheduleButton.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 250),

            colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
}
