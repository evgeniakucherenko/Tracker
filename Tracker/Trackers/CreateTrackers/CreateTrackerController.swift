//
//  CreateTrackerController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import Foundation
import UIKit

final class CreateTrackerController: UIViewController {
    
    weak var delegate: CreateTrackerControllerDelegate?
    private var categoryStore: TrackerCategoryStoreProtocol

    init(categoryStore: TrackerCategoryStoreProtocol) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
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
        [habitButton, irregularEventButton].forEach {
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
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    @objc private func habitButtonTapped() {
        let createHabitsController = CreateHabitsController(categoryStore: categoryStore)
        createHabitsController.createHabitsDelegate = self
        let navController = UINavigationController(rootViewController: createHabitsController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }

    @objc private func irregularEventButtonTapped() {
        let irregularEventController = IrregularEventController(categoryStore: categoryStore)
        irregularEventController.irregularEventDelegate = self
        let navController = UINavigationController(rootViewController: irregularEventController)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true, completion: nil)
    }
}

extension CreateTrackerController: CreateHabitsControllerDelegate & IrregularEventControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) {
        delegate?.didCreateTracker(tracker, inCategory: category)
        dismiss(animated: true, completion: nil)
    }

    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) {
        delegate?.didCreateIrregularEvent(tracker, inCategory: category)
        dismiss(animated: true, completion: nil)
    }
}



