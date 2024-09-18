//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 30.08.2024.
//

import Foundation
import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: CategorySelectionDelegate?
    private var selectedCategory: TrackerCategory?
    private var categoryStore: TrackerCategoryStoreProtocol
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            tableView.isHidden = categories.isEmpty
            placeholderImage.isHidden = !categories.isEmpty
            labelImage.isHidden = !categories.isEmpty
        }
    }
    
    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Elements
    private let placeholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholder
        return imageView
    }()
    
    private let labelImage: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "Привычки и события можно\n объединить по смыслу"
        return label
    }()
    
    private lazy var addCategoryButton: CustomButton = {
        let button = CustomButton(title: "Добавить категорию")
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        return tableView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        
        setupNavBar()
        setupViews()
        setupConstraints()
        
        categoryStore.subscribeToChanges { [weak self] in
            self?.loadCategories()
            self?.tableView.reloadData()
        }
        
        loadCategories()
    }
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        _ = TitlePopup(title: "Категория", navigationItem: navigationItem)
    }
    
    private func setupViews() {
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        
        [placeholderImage,labelImage, addCategoryButton, tableView].forEach {
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
    
    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        let createCategoryViewController = CreateCategoryViewController()
        createCategoryViewController.delegate = self 
        let navController = UINavigationController(rootViewController: createCategoryViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Category Operations
    private func loadCategories() {
        do {
            self.categories = try categoryStore.fetchAllCategories()
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
    }

    private func deleteCategory(_ category: TrackerCategory, at indexPath: IndexPath) {
           do {
               try categoryStore.deleteCategory(category)
               self.tableView.reloadData()
           } catch {
               print("Ошибка при удалении категории: \(error)")
           }
       }
    
    private func showEditCategoryScreen(for category: TrackerCategory) {
        let editCategoryVC = CreateCategoryViewController() // Здесь будет контроллер для редактирования 
        editCategoryVC.delegate = self
        let navController = UINavigationController(rootViewController: editCategoryVC)
        present(navController, animated: true, completion: nil)
    }
    
    private func confirmDeleteCategory(_ category: TrackerCategory, at indexPath: IndexPath) {
            let alert = UIAlertController(title: nil, message: "Эта категория точно не нужна?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
                self.deleteCategory(category, at: indexPath)
            }
            
            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            present(alert, animated: true, completion: nil)
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
               
                let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
                   
                   let editAction = UIAction(title: "Редактировать") { _ in
                       self.showEditCategoryScreen(for: category)
                   }
                   
                   let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                       self.confirmDeleteCategory(category, at: indexPath)
                   }
                   
                   return UIMenu(title: "", children: [editAction, deleteAction])
               }
            
               return config
           }
}

extension CategoryViewController: CategoryCreationDelegate {
    
    func didCreateCategory(_ categoryName: String) {
        do {
            let newCategory = TrackerCategory(title: categoryName, trackers: [])
            try categoryStore.addCategory(newCategory)
        } catch {
            print("Ошибка при сохранении категории: \(error)")
        }
    }
}

