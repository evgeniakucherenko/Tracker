//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 30.08.2024.
//

import Foundation
import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didCreateCategory(_ category: String)
}

final class CreateCategoryViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    weak var delegate: CategoryViewControllerDelegate?
    
    //MARK: - UI Elements
    private lazy var categoryTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Введите название категории"
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
        return textField
    }()
    
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: "Готово")
        button.update(backgroundColor: .grayColorYP)
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        _ = TitlePopup(title: "Новая категория", navigationItem: navigationItem)
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
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        guard let categoryName = categoryTextField.text, !categoryName.isEmpty else {
            return
        }
        delegate?.didCreateCategory(categoryName)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            doneButton.update(backgroundColor: .blackYP)
            doneButton.isEnabled = true
        } else {
            doneButton.update(backgroundColor: .grayColorYP)
            doneButton.isEnabled = false
        }
    }
}
