//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import Foundation
import UIKit

final class CreateTrackerController: UIViewController {
    
    weak var trackersViewControllerDelegate: (CreateHabitsControllerDelegate & IrregularEventControllerDelegate)?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        setupConstraints()
    }
    
    // MARK: - UI Elements
    private lazy var habitButton: CustomButton = {
        let button = CustomButton(title: "Привычка")
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: CustomButton = {
        let button = CustomButton(title: "Нерегулярное событие")
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        _ = TitlePopup(title: "Создание трекера", navigationItem: navigationItem)
    }
    
    private func setupViews() {
        [habitButton,irregularEventButton].forEach {
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            habitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 395),
            habitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.centerXAnchor.constraint(equalTo:  view.centerXAnchor),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func habitButtonTapped() {
        let сreateHabitsController = CreateHabitsController()
        сreateHabitsController.delegate = self
        let navController = UINavigationController(rootViewController: сreateHabitsController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func irregularEventButtonTapped() {
        let irregularEventController = IrregularEventController()
        irregularEventController.delegate = self 
        let navController = UINavigationController(rootViewController: irregularEventController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - CreateHabitsControllerDelegate & IrregularEventControllerDelegate
extension CreateTrackerController: CreateHabitsControllerDelegate & IrregularEventControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) {
        trackersViewControllerDelegate?.didCreateTracker(tracker, inCategory: category)
        dismiss(animated: true, completion: nil)
    }

    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) {
        trackersViewControllerDelegate?.didCreateIrregularEvent(tracker, inCategory: category)
        dismiss(animated: true, completion: nil)
    }
}
