//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import Foundation
import UIKit

final class CreateTrackerController: UIViewController {
    
    //MARK: - Lifycylce
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
        return CustomButton(title: "Нерегулярное событие")
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
            
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.centerXAnchor.constraint(equalTo:  view.centerXAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func habitButtonTapped() {
        let сreateHabitsController = CreateHabitsController()
        let navController = UINavigationController(rootViewController: сreateHabitsController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
}
