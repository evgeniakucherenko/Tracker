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
    
    private var selectedDays: Set<Weekday> = []
    weak var delegate: CreateHabitsControllerDelegate?
    private var selectedCategory: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Elements
    private lazy var cancelButton: UIButton = {
        let button = createButton(title: "Отменить", backgroundColor: .clear)
        button.setTitleColor(UIColor(named: "red_YP"), for: .normal)
        button.layer.borderColor = UIColor(named: "red_YP")?.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = createButton(title: "Создать", backgroundColor: .grayColorYP)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
        dismiss(animated: true, completion: nil)
    }

    private lazy var nameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.placeholder = "Введите название трекера"
        return textField
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
         categoryButton, scheduleButton, separatorLine].forEach {
            view.addSubview($0)
        }
    }
    
    // MARK: - Actions
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
        let selectedDaysText = days.map { $0.shortName }.joined(separator: ", ")
        scheduleButton.update(title: "Расписание", subtitle: selectedDaysText)
    }
}

extension CreateHabitsController {
    // MARK: - Layout
    private func setupConstraints() {
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
            
            categoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            categoryButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
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

extension CreateHabitsController: CategoryViewControllerDelegate {
    func didCreateCategory(_ category: String) {
        selectedCategory = category
        categoryButton.update(title: "Категория", subtitle: category)
    }
}
