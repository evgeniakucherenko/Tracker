import UIKit

class BaseCreateTrackerController<ViewModelType: BaseCreateTrackerViewModel>: UIViewController, UITextFieldDelegate {
    // MARK: - Properties
    var viewModel: ViewModelType

    weak var categorySelectionDelegate: CategorySelectionDelegate?
    var coordinator: TrackersCoordinator?

    let scrollView = UIScrollView()
    let contentView = UIView()

    lazy var cancelButton: UIButton = {
        let cancel = NSLocalizedString("cancel", comment:"")
        let button = createButton(title: cancel, backgroundColor: .clear)
        button.setTitleColor(UIColor(named: "red_YP"), for: .normal)
        button.layer.borderColor = UIColor(named: "red_YP")?.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var createButton: UIButton = {
        let create = NSLocalizedString("create", comment: "")
        let button = createButton(title: create, backgroundColor: .grayColorYP)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField()
        let trackerNameTextField = NSLocalizedString("trackerNameTextField", comment: "")
        textField.placeholder = trackerNameTextField
        textField.autocapitalizationType = .words
        textField.delegate = self
        return textField
    }()

    lazy var errorLabel: UILabel = {
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

    let emojiCollectionView = EmojiCollectionView()
    let colorsCollectionView = ColorsCollectionView()

    var categoryButtonTopConstraint: NSLayoutConstraint?

    // MARK: - Init
    init(viewModel: ViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setupNavBar()
        setupViews()
        setupScrollView()
        setupConstraints()
        setupCollectionViewCallbacks()
        bindBaseViewModel()
        updateTheme()
    }
    
    func setupConstraints() {

            emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
            colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
            emojiCollectionViewTopConstraint = emojiCollectionView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 190)

            NSLayoutConstraint.activate([
                nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                nameTextField.heightAnchor.constraint(equalToConstant: 75),

                errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
                errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                errorLabel.heightAnchor.constraint(equalToConstant: 22),

                emojiCollectionViewTopConstraint,
                emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
                emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
                emojiCollectionView.heightAnchor.constraint(equalToConstant: 250),

                colorsCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
                colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
                colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
                colorsCollectionView.heightAnchor.constraint(equalToConstant: 250),

                cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                cancelButton.heightAnchor.constraint(equalToConstant: 60),
                cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 40),

                createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                createButton.heightAnchor.constraint(equalToConstant: 60),
                createButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 40),
                createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

                cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
                cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
            ])
        }

    // MARK: - Setup Methods
    func createButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = backgroundColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    func setupNavBar() {
        let title = NSLocalizedString("newHabit", comment: "")
        _ = TitlePopup(title: title, navigationItem: navigationItem)
    }

    func setupViews() {
        [cancelButton, createButton, nameTextField, errorLabel, emojiCollectionView, colorsCollectionView].forEach {
            contentView.addSubview($0)
        }
    }

    func setupScrollView() {
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

    var emojiCollectionViewTopConstraint: NSLayoutConstraint!

    func setupCollectionViewCallbacks() {
        emojiCollectionView.onEmojiSelected = { [weak self] emoji in
            self?.viewModel.selectEmoji(emoji)
        }

        colorsCollectionView.onColorSelected = { [weak self] color in
            self?.viewModel.selectColor(color)
        }
    }

    func bindBaseViewModel() {
        viewModel.onCreateButtonStateChanged = { [weak self] isEnabled in
            guard let self = self else { return }
            if isEnabled {
                self.createButton.backgroundColor = .text
                self.createButton.isEnabled = true
            } else {
                self.createButton.backgroundColor = .grayColorYP
                self.createButton.isEnabled = false
            }
        }

        viewModel.onErrorLabelVisibilityChanged = { [weak self] isVisible in
            guard let self = self else { return }
            self.errorLabel.isHidden = !isVisible
            if let constraint = self.categoryButtonTopConstraint {
                constraint.constant = isVisible ? 24 : 8
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }

        viewModel.onCategoryButtonSubtitleChanged = { _ in
            // Будет обновлено в наследниках, у которых есть categoryButton
        }
    }

    func updateTheme() {
        view.backgroundColor = ColorPalette.backgroundColor
    }

    // MARK: - Actions
    @objc func createButtonTapped() {
        guard let (tracker, category) = viewModel.createTracker() else {
            return
        }
        handleCreateTracker(tracker: tracker, category: category)
    }
    

    @objc func cancelButtonTapped() {
        closeModalAndSwitchToTab(index: 0)
    }

    func handleCreateTracker(tracker: Tracker, category: String) {
        // Переопределяется в наследниках
    }

    func closeModalAndSwitchToTab(index: Int) {
        guard let window = UIApplication.shared.windows.first else { return }

        if let tabBarController = window.rootViewController as? CustomTabBarController {
            tabBarController.selectedIndex = index
        }

        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""

        guard let stringRange = Range(range, in: currentText) else { return false }
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if !updatedText.isEmpty {
            let firstLetter = updatedText.prefix(1).capitalized
            let remainingText = updatedText.dropFirst()
            updatedText = firstLetter + remainingText.lowercased()
        }

        if !viewModel.validateNameLength(updatedText) {
            viewModel.showError(true)
            return false
        } else {
            viewModel.showError(false)
            textField.text = updatedText
            viewModel.updateTrackerName(updatedText)
            return false
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.showError(false)
        viewModel.updateTrackerName("")
        return true
    }
}
