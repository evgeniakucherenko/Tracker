//
//  ViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 25.08.2024.
//

import UIKit
import Foundation


final class TrackersViewController: UIViewController,
                                    CreateHabitsControllerDelegate {

    var categories: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    private var filteredTrackers: [Tracker] = []
    
    private var currentDate: Date {
        return datePicker.date
    }

    // MARK: - UI Elements
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let placeholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholder
        return imageView
    }()

    private let labelImage: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = "Что будем отслеживать?"
        return label
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()

    private let weekdayMapping: [Int: Weekday] = [
        1: .sunday,
        2: .monday,
        3: .tuesday,
        4: .wednesday,
        5: .thursday,
        6: .friday,
        7: .saturday
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()

        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)

        dateChanged()
    }

    @objc private func dateChanged() {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        updateUIForSelectedDay(selectedDayOfWeek: selectedDayOfWeek)
    }

    private func updateUIForSelectedDay(selectedDayOfWeek: Int) {
        guard let selectedWeekday = weekdayMapping[selectedDayOfWeek] else {
            assertionFailure("Ошибка: выбранный день недели не соответствует ни одному из значений Weekday")
            return
        }

        let hasTrackersForSelectedDay = categories.flatMap { $0.trackers }.contains { tracker in
            tracker.schedule.contains(selectedWeekday)
        }

        DispatchQueue.main.async {
            let isCollectionViewHidden = !hasTrackersForSelectedDay
            self.collectionView.isHidden = isCollectionViewHidden
            self.placeholderImage.isHidden = !isCollectionViewHidden
            self.labelImage.isHidden = !isCollectionViewHidden
        }
    }

    // MARK: - CreateHabitsControllerDelegate
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) {
        if let index = categories.firstIndex(where: { $0.title == category }) {
        
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            
            let updatedCategory = TrackerCategory(title: categories[index].title, trackers: updatedTrackers)
            
            var newCategories = categories
            newCategories[index] = updatedCategory
            categories = newCategories
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            categories.append(newCategory)
        }

        self.collectionView.reloadData()
        self.updateUIForSelectedDay(selectedDayOfWeek: Calendar.current.component(.weekday, from: self.currentDate))
    }
    
    private func toggleTrackerCompletion(tracker: Tracker) {
        if completedTrackers.contains(tracker.id) {
            completedTrackers.remove(tracker.id)
        } else {
            completedTrackers.insert(tracker.id)
        }
        collectionView.reloadData()
    }
}

// MARK: - Setup UI
extension TrackersViewController {

    private func setupUI() {
        setupNavBar()

        [placeholderImage, labelImage, datePicker, collectionView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            placeholderImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -246),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            labelImage.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            labelImage.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func setupNavBar() {
        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .black
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)

        let leftBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)

        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    @objc private func addButtonTapped() {
        let createHabitsController = CreateHabitsController()
        createHabitsController.delegate = self
        let navController = UINavigationController(rootViewController: createHabitsController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegateFlowLayout,
                                  UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as! TrackerCell
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        let categoryTitle = categories[indexPath.section].title

        let isRepeatedCategory = indexPath.item > 0

        cell.configure(with: tracker.name, days: "1 день", category: categoryTitle, emoji: tracker.emoji, color: tracker.color, isRepeatedCategory: isRepeatedCategory)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 2
        let spacingBetweenCells: CGFloat = 9
        let sideInset: CGFloat = 16
        let totalSpacing = (numberOfItemsPerRow - 1) * spacingBetweenCells + 2 * sideInset
        let width = (collectionView.bounds.width - totalSpacing) / numberOfItemsPerRow

        return CGSize(width: width, height: 148)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
    }
}
