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
    weak var delegate: CategoryViewControllerDelegate?
    private var selectedCategory: String?
    
    private var categories: [String] = [] {
        didSet {
            tableView.isHidden = categories.isEmpty
            placeholderImage.isHidden = !categories.isEmpty
            labelImage.isHidden = !categories.isEmpty
        }
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "categoryCell")
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
    
    // MARK: - Private Methods (User Defaults)
    private func saveCategories() {
        UserDefaults.standard.set(categories, forKey: "savedCategories")
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: "savedCategories") as? [String] {
            categories = savedCategories
        }
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
        let isSelected = category == selectedCategory
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == categories.count - 1
        
        let isSingleItem = categories.count == 1
        cell.configure(with: category, isSelected: isSelected, isFirst: isFirst, isLast: isLast, isSingleItem: isSingleItem)
        
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        tableView.reloadData()
            
        delegate?.didCreateCategory(selectedCategory ?? "")
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { 
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension CategoryViewController: CategoryViewControllerDelegate {
    // MARK: - CategoryViewControllerDelegate
    func didCreateCategory(_ category: String) {
        categories.append(category)
        saveCategories()
        tableView.reloadData()
    }
}



