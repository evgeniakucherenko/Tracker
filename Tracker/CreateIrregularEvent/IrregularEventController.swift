import UIKit

final class IrregularEventController: BaseCreateTrackerController<IrregularEventViewModel>, CategorySelectionDelegate {
    weak var irregularEventDelegate: IrregularEventControllerDelegate?

    private lazy var categoryButton: CustomSelectionButton = {
        let category = NSLocalizedString("category", comment: "")
        let button = CustomSelectionButton(title: category)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }

    override func setupNavBar() {
        let newirregularEventButton = NSLocalizedString("newirregularEventButton", comment: "")
        _ = TitlePopup(title: newirregularEventButton, navigationItem: navigationItem)
    }

    override func setupViews() {
        super.setupViews()
        contentView.addSubview(categoryButton)
    }
    
    override func setupConstraints() {
            super.setupConstraints() 
            NSLayoutConstraint.deactivate([emojiCollectionViewTopConstraint])

            categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8)
            NSLayoutConstraint.activate([
                categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                categoryButtonTopConstraint!,
                categoryButton.heightAnchor.constraint(equalToConstant: 75),

                emojiCollectionView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 32)
            ])
        }

    override func bindBaseViewModel() {
        super.bindBaseViewModel()

        viewModel.onCategoryButtonSubtitleChanged = { [weak self] subtitle in
            guard let self = self else { return }
            self.categoryButton.update(title: "Категория", subtitle: subtitle)
        }
    }
    
    override func handleCreateTracker(tracker: Tracker, category: String) {
        Task {
            await irregularEventDelegate?.didCreateIrregularEvent(tracker, inCategory: category)
            closeModalAndSwitchToTab(index: 0)
        }
    }

    @objc private func categoryButtonTapped() {
        let categoryViewModel = CategoryViewModel(categoryStore: viewModel.categoryStoreRef)
        let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
        categoryViewController.delegate = self

        let navController = UINavigationController(rootViewController: categoryViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }

    func didSelectCategory(_ categoryName: String) {
        viewModel.selectCategory(categoryName)
    }
}
