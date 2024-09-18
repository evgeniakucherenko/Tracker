//
//  ViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 25.08.2024.
//

import UIKit
import Foundation

final class TrackersViewController: UIViewController,
                                    CreateTrackerControllerDelegate {
    
    // MARK: - Properties
    private var trackerStore: TrackerStoreProtocol
    private var categoryStore: TrackerCategoryStoreProtocol
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<UUID> = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private var currentDate: Date {
        return datePicker.date
    }
    
    private var filteredCategories: [TrackerCategory] {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        
        return categories.filter { category in
            let trackersForSelectedDay = category.trackers.filter { tracker in
                if tracker.schedule.isEmpty {
                    let isToday = Calendar.current.isDate(currentDate, inSameDayAs: Date())
                    return isToday
                } else {
                    let containsDay = tracker.schedule.contains(weekdayMapping[selectedDayOfWeek]!)
                    return containsDay
                }
            }
            return !trackersForSelectedDay.isEmpty
        }
    }

    init(trackerStore: TrackerStoreProtocol, categoryStore: TrackerCategoryStoreProtocol) {
        self.trackerStore = trackerStore
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        setupNavBar()
        setupUI()
        
        trackerStore.subscribeToChanges { [weak self] in
            self?.loadInitialData()
            self?.collectionView.reloadData()
        }
        
        loadInitialData()
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        dateChanged()
    }
    
    // MARK: - Load Data
    private func loadInitialData() {
        do {
            _ = try trackerStore.fetchAllTrackers()
            loadCompletedTrackers()
        } catch {
            print("[TrackersViewController] Ошибка при загрузке трекеров: \(error.localizedDescription)")
        }
        
        loadCategories()
        
        let isContentAvailable = !categories.flatMap { $0.trackers }.isEmpty
        updateScrollViewState(isContentAvailable: isContentAvailable)
    }
    
    private func loadCategories() {
        do {
            categories = try categoryStore.fetchAllCategories()
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
    }
    
    private func loadCompletedTrackers() {
        do {
            let trackerRecords = try trackerStore.fetchAllTrackerRecords() // Используем метод протокола
            let today = Date()
            
            completedTrackers = Set(trackerRecords
                .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
                .map { $0.id }
            )
        } catch {
            print("[TrackersViewController] Ошибка при загрузке выполненных трекеров: \(error)")
        }
    }
    
    // MARK: - Actions
    @objc private func dateChanged() {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)
        
        updateUIForSelectedDay(selectedDayOfWeek)
        collectionView.reloadData()
    }
    
    @objc private func addButtonTapped() {
        let createTrackerController = CreateTrackerController(categoryStore: categoryStore)
        createTrackerController.delegate = self
        let navController = UINavigationController(rootViewController: createTrackerController)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - UI Updates
    private func updateUIForSelectedDay(_ selectedDayOfWeek: Int) {
        let trackersForSelectedDay = getTrackersForSelectedDay(selectedDayOfWeek)
        DispatchQueue.main.async {
            let isContentAvailable = !trackersForSelectedDay.isEmpty // Инвертируем проверку
            self.updateScrollViewState(isContentAvailable: isContentAvailable)
            if isContentAvailable {
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - Tracker Management
    private func addTracker(_ tracker: Tracker, to category: String) {
        do {
            let updatedCategory: TrackerCategory
            if let index = categories.firstIndex(where: { $0.title == category }) {
                var updatedTrackers = categories[index].trackers
                updatedTrackers.append(tracker)
                updatedCategory = TrackerCategory(title: categories[index].title, trackers: updatedTrackers)
                categories[index] = updatedCategory
                try categoryStore.updateCategory(updatedCategory)
            } else {
                updatedCategory = TrackerCategory(title: category, trackers: [tracker])
                categories.append(updatedCategory)
                try categoryStore.addCategory(updatedCategory)
            }
            
            try trackerStore.addNewTracker(tracker)
            updateUIForSelectedDay(Calendar.current.component(.weekday, from: currentDate))
            
        } catch {
            print("[TrackersViewController] Ошибка при добавлении трекера: \(error)")
        }
    }
    
    private func toggleTrackerCompletion(_ tracker: Tracker) {
        guard currentDate <= Date() else { return }
        
        do {
            try trackerStore.toggleTrackerCompletion(tracker, on: currentDate)
            collectionView.reloadData()
        } catch {
            print("[TrackersViewController] Ошибка при изменении статуса выполнения трекера: \(error)")
        }
    }
    
    private func getCompletionCount(for tracker: Tracker) -> Int {
        do {
            return try trackerStore.getCompletionCount(for: tracker)
        } catch {
            print("[TrackersViewController] Ошибка при подсчете выполненных дней: \(error)")
            return 0
        }
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        return completedTrackers.contains(tracker.id)
    }
    
    private func getTrackersForSelectedDay(_ selectedDayOfWeek: Int) -> [Tracker] {
        let trackers = filteredCategories.flatMap { $0.trackers }.filter { tracker in
            if tracker.schedule.isEmpty {
                return Calendar.current.isDate(currentDate, inSameDayAs: Date())
            } else {
                return tracker.schedule.contains(weekdayMapping[selectedDayOfWeek]!)
            }
        }
        return trackers
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDelegateFlowLayout,
                                  UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let selectedDayOfWeek = Calendar.current.component(.weekday, from: currentDate)

        guard let weekday = weekdayMapping[selectedDayOfWeek] else {
            print("Ошибка: Не удалось получить день недели.")
            return 0
        }

        return filteredCategories[section].trackers.filter { tracker in
            if tracker.schedule.isEmpty {
                return Calendar.current.isDate(currentDate, inSameDayAs: Date())
            } else {
                return tracker.schedule.contains(weekday)
            }
        }.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as! TrackerCell

        let tracker = filteredCategories[indexPath.section].trackers.filter { tracker in
            if tracker.schedule.isEmpty {
                return Calendar.current.isDate(currentDate, inSameDayAs: Date())
            } else {
                return tracker.schedule.contains(weekdayMapping[Calendar.current.component(.weekday, from: currentDate)]!)
            }
        }[indexPath.item]

        cell.onCompletionToggle = { [weak self] in
            self?.toggleTrackerCompletion(tracker)
        }

        let categoryTitle = filteredCategories[indexPath.section].title
        let isCompleted = isTrackerCompleted(tracker, on: currentDate)
        let completionCount = getCompletionCount(for: tracker)
        
        cell.configure(with: tracker.name, days: completionCount, category: categoryTitle, emoji: tracker.emoji, color: tracker.color, isRepeatedCategory: indexPath.item > 0, isCompleted: isCompleted)

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

// MARK: - CreateHabitsControllerDelegate & IrregularEventControllerDelegate
extension TrackersViewController {
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
}

// MARK: - Setup UI
extension TrackersViewController {

    private func setupUI() {
        
        [scrollView, placeholderImage, labelImage, collectionView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            labelImage.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            labelImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        datePicker.translatesAutoresizingMaskIntoConstraints = false
    
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        }

    private func updateScrollViewState(isContentAvailable: Bool) {
        collectionView.isHidden = !isContentAvailable
        placeholderImage.isHidden = isContentAvailable
        labelImage.isHidden = isContentAvailable
    }
}


