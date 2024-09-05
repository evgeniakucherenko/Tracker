//
//  CreatingHabitsController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import Foundation
import UIKit

protocol CreateHabitsControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String)
}

final class CreateHabitsController: UIViewController,
                                    ScheduleViewControllerDelegate {
    
    // MARK: - Properties
    weak var delegate: CreateHabitsControllerDelegate?
    
    private var selectedDays: Set<Weekday> = []
    private var selectedCategory: String?
    private var categoryButtonTopConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        setupConstraints()
        
        nameTextField.delegate = self
        
        updateCreateButtonState()
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - UI Elements
    private lazy var cancelButton: UIButton = {
        let button = createButton(title: "Отменить", backgroundColor: .clear)
        button.setTitleColor(UIColor(named: "red_YP"), for: .normal)
        button.layer.borderColor = UIColor(named: "red_YP")?.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = createButton(title: "Создать", backgroundColor: .grayColorYP)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Введите название трекера"
        textField.autocapitalizationType = .words
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .redYP
        label.font = .systemFont(ofSize: 17)
        label.isHidden = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var categoryButton: CustomSelectionButton = {
        let button = CustomSelectionButton(title: "Категория")
        button.layer.cornerRadius = 16
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var scheduleButton: CustomSelectionButton = {
        let button = CustomSelectionButton(title: "Расписание")
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
        _ = TitlePopup(title: "Новая привычка", navigationItem: navigationItem)
    }
    
    private func setupViews() {
        [cancelButton,createButton,nameTextField,
         categoryButton, scheduleButton, separatorLine, errorLabel].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - Actions
    private func updateCreateButtonState() {
        let isNameFilled = !(nameTextField.text?.isEmpty ?? true)
        let isCategorySelected = selectedCategory != nil
        let isScheduleSelected = !selectedDays.isEmpty
            
        if isNameFilled && isCategorySelected && isScheduleSelected {
            createButton.backgroundColor = .blackYP
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = .grayColorYP
            createButton.isEnabled = false
        }
    }
    
    @objc private func createButtonTapped() {
        guard let trackerName = nameTextField.text, !trackerName.isEmpty else {
            return
        }

        let tracker = Tracker(
            id: UUID(),
            name: trackerName,
            color: .selection14,
            emoji: "🙂",
            schedule: selectedDays
        )

        delegate?.didCreateTracker(tracker, inCategory: selectedCategory ?? "Без категории")
        closeModalAndSwitchToTab(index: 0)
    }
    
    @objc private func cancelButtonTapped() {
        closeModalAndSwitchToTab(index: 0)
    }
    
    @objc private func categoryButtonTapped() {
        let categoryViewController = CategoryViewController()
        categoryViewController.delegate = self
        let navController = UINavigationController(rootViewController: categoryViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
       
    @objc private func scheduleButtonTapped() {
        let scheduleViewController = ScheduleViewController(selectedDays: selectedDays)
        scheduleViewController.delegate = self
        let navController = UINavigationController(rootViewController: scheduleViewController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Delegate Methods
    func didSelect(days: Set<Weekday>) {
        selectedDays = days
        
        if selectedDays.count == Weekday.allCases.count {
            scheduleButton.update(title: "Расписание", subtitle: "Каждый день")
        } else {
            let selectedDaysText = days.map { $0.shortName }.joined(separator: ", ")
            scheduleButton.update(title: "Расписание", subtitle: selectedDaysText)
        }
        
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    private func closeModalAndSwitchToTab(index: Int) {
        guard let window = UIApplication.shared.windows.first else { return }

        if let tabBarController = window.rootViewController as? TabBarController {
            tabBarController.selectedIndex = index
        }

        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - CategoryViewControllerDelegate & UITextFieldDelegate
extension CreateHabitsController: CategoryViewControllerDelegate & UITextFieldDelegate {
    
    func didCreateCategory(_ category: String) {
        selectedCategory = category
        categoryButton.update(title: "Категория", subtitle: category)
        updateCreateButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        var updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if !updatedText.isEmpty {
            let firstLetter = updatedText.prefix(1).capitalized
            let remainingText = updatedText.dropFirst()
            updatedText = firstLetter + remainingText.lowercased()
        }
        
        if updatedText.count > 38 {
            errorLabel.isHidden = false
            categoryButtonTopConstraint?.constant = 24
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            return false
        } else {
            errorLabel.isHidden = true
            categoryButtonTopConstraint?.constant = 8
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            textField.text = updatedText
            updateCreateButtonState()
            return false
        }
    }
}

extension CreateHabitsController {
    // MARK: - Layout
    private func setupConstraints() {
            
        categoryButtonTopConstraint = categoryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8)
            
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
          
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
                
            errorLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            errorLabel.heightAnchor.constraint(equalToConstant: 22),
                
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryButtonTopConstraint!,
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
                
            scheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 0),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),
                
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            separatorLine.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

    
