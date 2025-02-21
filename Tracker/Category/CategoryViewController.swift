import Foundation
import UIKit

final class CategoryViewController: ThemedViewController {
    
    // MARK: - Properties
    weak var delegate: CategorySelectionDelegate?
    private var selectedCategory: TrackerCategory?
    private var viewModel: CategoryViewModel

    private var categories: [TrackerCategory] = [] {
        didSet {
            tableView.isHidden = categories.isEmpty
            placeholderImage.isHidden = !categories.isEmpty
            labelImage.isHidden = !categories.isEmpty
        }
    }

    // MARK: - UI Elements
    private let placeholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder_image")
        imageView.isHidden = true
        return imageView
    }()
    
    private let labelImage: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        let categoryTitleAdditional = NSLocalizedString("categoryTitleAdditional", comment: "")
        label.text = categoryTitleAdditional
        label.isHidden = true
        return label
    }()
    
    private lazy var addCategoryButton: CustomButton = {
        let addCategory = NSLocalizedString("addCategory", comment: "")
        let button = CustomButton(title: addCategory)
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: - Initializer
    init(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTheme() {
        super.updateTheme()
        view.backgroundColor = ColorPalette.backgroundColor
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupViews()
        setupConstraints()
        setupBindings()
        
        viewModel.fetchCategories()
        updateTheme()
    }
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        let category = NSLocalizedString("category", comment: "")
        _ = TitlePopup(title: category, navigationItem: navigationItem)
    }
    
    private func setupViews() {
        [placeholderImage, labelImage, addCategoryButton, tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -386),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            labelImage.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            labelImage.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20)
        ])
    }
    
    private func setupBindings() {
        viewModel.onCategoriesUpdated = { [weak self] updatedCategories in
            self?.categories = updatedCategories
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { errorMessage in
            print("Error: \(errorMessage)")
        }
    }
    
    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        let createCategoryViewModel = CreateCategoryViewModel()
        let createCategoryVC = CreateCategoryViewController(viewModel: createCategoryViewModel)
        createCategoryVC.onCategoryCreated = { [weak self] newCategory in
            self?.viewModel.addCategory(newCategory.title)
        }
        let navController = UINavigationController(rootViewController: createCategoryVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.reuseIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        let category = categories[indexPath.row]
        let isSelected = category.title == selectedCategory?.title
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == categories.count - 1
        let isSingleItem = categories.count == 1
        cell.configure(with: category, isSelected: isSelected, isFirst: isFirst, isLast: isLast, isSingleItem: isSingleItem)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        tableView.reloadData()
        
        delegate?.didSelectCategory(selectedCategory?.title ?? "")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let category = categories[indexPath.row]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { [weak self] _ in
                self?.presentEditCategoryScreen(for: category)
            }

            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.deleteCategory(category, at: indexPath)
            }

            return UIMenu(title: category.title, children: [editAction, deleteAction])
        }
    }
    
    private func presentEditCategoryScreen(for category: TrackerCategory) {
        let editCategoryViewModel = CreateCategoryViewModel()
        let editCategoryVC = CreateCategoryViewController(viewModel: editCategoryViewModel, editableCategory: category)
        
        editCategoryVC.onCategoryUpdated = { [weak self] updatedCategory in
            do {
                try self?.viewModel.updateCategory(category, with: updatedCategory.title)
                self?.viewModel.fetchCategories()
            } catch {
                print("Ошибка обновления категории: \(error.localizedDescription)")
            }
        }
        
        let navController = UINavigationController(rootViewController: editCategoryVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    private func deleteCategory(_ category: TrackerCategory, at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Удалить категорию?",
            message: "Вы уверены, что хотите удалить категорию \(category.title)? Это действие нельзя отменить.",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

}
