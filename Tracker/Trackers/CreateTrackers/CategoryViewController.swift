//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 30.08.2024.
//

import Foundation
import UIKit

final class CategoryViewController: UIViewController {
    
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
    
    //MARK: - Lifycylce
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        _ = TitlePopup(title: "Категория", navigationItem: navigationItem)
    }
    
    private func setupViews() {
        [placeholderImage,labelImage, addCategoryButton].forEach {
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
            addCategoryButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
            
        ])
    }
    
    // MARK: - Actions
    @objc private func addCategoryButtonTapped() {
        let createCategoryViewController = CreateCategoryViewController()
        let navController = UINavigationController(rootViewController: createCategoryViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
}
