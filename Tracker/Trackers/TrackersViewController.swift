//
//  ViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 25.08.2024.
//

import UIKit
import Foundation

final class TrackersViewController: UIViewController,
                                    CreateHabitsControllerDelegate,
                                    IrregularEventControllerDelegate {

    var categories: [TrackerCategory] = []
    var completedTrackers: Set<UUID> = []
    private var trackers: [Tracker] = []

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
//        addTapGestureToHideKeyboard() 
    }

    // MARK: - Actions
    @objc private func dateChanged() {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        updateUIForSelectedDay(selectedDayOfWeek)
    }

    @objc private func addButtonTapped() {
        let createTrackerController = CreateTrackerController()
        createTrackerController.trackersViewControllerDelegate = self
        let navController = UINavigationController(rootViewController: createTrackerController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }

    // MARK: - UI Updates
    private func updateUIForSelectedDay(_ selectedDayOfWeek: Int) {
        let trackersForSelectedDay = getTrackersForSelectedDay(selectedDayOfWeek)
        DispatchQueue.main.async {
            let isCollectionViewHidden = trackersForSelectedDay.isEmpty
            self.collectionView.isHidden = isCollectionViewHidden
            self.placeholderImage.isHidden = !isCollectionViewHidden
            self.labelImage.isHidden = !isCollectionViewHidden
            self.collectionView.reloadData()
        }
    }

    // MARK: - Tracker Management
    private func toggleTrackerCompletion(_ tracker: Tracker) {
        guard currentDate <= Date() else { return }

        if completedTrackers.contains(tracker.id) {
            completedTrackers.remove(tracker.id)
        } else {
            completedTrackers.insert(tracker.id)
        }
        collectionView.reloadData()
    }

    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        return completedTrackers.contains(tracker.id)
    }

    private func getTrackersForSelectedDay(_ selectedDayOfWeek: Int) -> [Tracker] {
        return categories.flatMap { $0.trackers }.filter { tracker in
            if tracker.schedule.isEmpty {
                return Calendar.current.isDate(currentDate, inSameDayAs: Date())
            } else {
                return tracker.schedule.contains(weekdayMapping[selectedDayOfWeek]!)
            }
        }
    }

    // MARK: - CreateHabitsControllerDelegate & IrregularEventControllerDelegate
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) {
        addTracker(tracker, to: category)
        collectionView.reloadData()
        updateUIForSelectedDay(Calendar.current.component(.weekday, from: currentDate))
    }

    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) {
        addTracker(tracker, to: category)
        collectionView.reloadData()
        updateUIForSelectedDay(Calendar.current.component(.weekday, from: currentDate))
    }

    private func addTracker(_ tracker: Tracker, to category: String) {
        if let index = categories.firstIndex(where: { $0.title == category }) {
            var updatedTrackers = categories[index].trackers
            updatedTrackers.append(tracker)
            
            let updatedCategory = TrackerCategory(title: categories[index].title, trackers: updatedTrackers)
            
            categories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: category, trackers: [tracker])
            categories.append(newCategory)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegateFlowLayout,  
                                  UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        return categories[section].trackers.filter { tracker in
            if tracker.schedule.isEmpty {
                return Calendar.current.isDate(currentDate, inSameDayAs: Date())
            } else {
                return tracker.schedule.contains(weekdayMapping[selectedDayOfWeek]!)
            }
        }.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as! TrackerCell
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        
        let trackersForSelectedDay = categories[indexPath.section].trackers.filter { tracker in
            if tracker.schedule.isEmpty {
                return Calendar.current.isDate(currentDate, inSameDayAs: Date())
            } else {
                return tracker.schedule.contains(weekdayMapping[selectedDayOfWeek]!)
            }
        }

        let tracker = trackersForSelectedDay[indexPath.item]
        let categoryTitle = categories[indexPath.section].title
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        let completionCount = completedTrackers.filter { $0 == tracker.id }.count

        cell.configure(with: tracker.name, days: completionCount, category: categoryTitle, emoji: tracker.emoji, color: tracker.color, isRepeatedCategory: indexPath.item > 0, isCompleted: isCompleted)

        cell.onCompletionToggle = { [weak self] in
            self?.toggleTrackerCompletion(tracker)
        }

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

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
}
