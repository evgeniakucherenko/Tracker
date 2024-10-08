//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 30.08.2024.
//

import Foundation
import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Properties
    weak var scheduleDelegate: ScheduleViewControllerDelegate?
    private var selectedDays: Set<Weekday> = []
    
    //MARK: - UI Elements
    private let tableView = UITableView()
    
    private lazy var doneButton: CustomButton = {
        let button = CustomButton(title: "Готово")
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializer
    init(selectedDays: Set<Weekday>) {
        self.selectedDays = selectedDays
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        
        setupNavBar()
        setupViews()
        setupConstraints()
        setupTableView()
    }
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        _ = TitlePopup(title: "Расписание", navigationItem: navigationItem)
    }
    
    private func setupViews() {
        [doneButton, tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -40)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        scheduleDelegate?.didSelect(days: selectedDays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return Weekday.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseIdentifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let weekday = Weekday.allCases[indexPath.row]
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == Weekday.allCases.count - 1
        
        cell.configure(with: weekday, isSelected: selectedDays.contains(weekday), isFirst: isFirst, isLast: isLast)
        
        cell.onSwitchToggled = { [weak self] isOn in
            if isOn {
                self?.selectedDays.insert(weekday)
            } else {
                self?.selectedDays.remove(weekday)
            }
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 75 }
}
