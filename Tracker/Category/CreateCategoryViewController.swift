
import Foundation
import UIKit

final class CreateCategoryViewController: UIViewController {

    // MARK: - Properties
    private var viewModel: CreateCategoryViewModel
    weak var delegate: CreateCategoryViewControllerDelegate?

    //MARK: - UI Elements
    private lazy var categoryTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = NSLocalizedString("addCategoryName", comment: "")
        textField.addTarget(self,
                            action: #selector(textFieldDidChange(_:)),
                            for: .editingChanged)
        return textField
    }()

    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: NSLocalizedString("done", comment: ""))
        button.isEnabled = false
        button.addTarget(self,
                         action: #selector(doneButtonTapped),
                         for: .touchUpInside)
        return button
    }()

    // MARK: - Initializer
    init(viewModel: CreateCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupNavBar()
        setupViews()
        setupConstraints()
        bindViewModel()
        updateTheme()
    }

    private func setupNavBar() {
        let title = NSLocalizedString("newCategory", comment: "")
        _ = TitlePopup(title: title, navigationItem: navigationItem)
    }

    private func setupViews() {
        [categoryTextField, doneButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    private func bindViewModel() {
        viewModel.onValidationChange = { [weak self] isValid in
            self?.doneButton.isEnabled = isValid
        }
    }

    @objc private func updateTheme() {
        view.backgroundColor = ColorPalette.backgroundColor
    }

    // MARK: - Actions
    @objc private func doneButtonTapped() {
        guard let categoryName = categoryTextField.text else { return }
        viewModel.createCategory(categoryName)
        delegate?.didCreateCategory(name: categoryName)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.updateCategoryName(textField.text)
    }
}
