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

    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let categoryStore = TrackerCategoryStore()
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<UUID> = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private var currentDate: Date {
        return datePicker.date
    }
    
    private var filteredCategories: [TrackerCategory] {
        return categories.filter { !$0.trackers.isEmpty }
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
        setupScrollView()
        setupUI()
        
        loadInitialData()

        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        dateChanged()
    }
    
    // MARK: - Load Data
    private func loadInitialData() {
        do {
            let trackers = try trackerStore.fetchAllTrackers()
            loadCompletedTrackers()
        } catch {
            print("[TrackersViewController] Ошибка при загрузке трекеров: \(error.localizedDescription)")
        }
            
        loadCategories()
    }
    
    private func loadCompletedTrackers() {
        do {
            let trackerRecords = try trackerStore.trackerRecordStore.fetchAllTrackerRecords()
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

        do {
            let trackerRecords = try trackerStore.trackerRecordStore.fetchAllTrackerRecords()
            let today = Calendar.current.startOfDay(for: currentDate)

            if let existingRecord = trackerRecords.first(where: {
                $0.id == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: today)
            }) {
                try trackerStore.trackerRecordStore.deleteTrackerRecord(for: tracker.id, on: today)
                completedTrackers.remove(tracker.id)
            } else {
                let newRecord = TrackerRecord(id: tracker.id, date: today)
                try trackerStore.trackerRecordStore.addTrackerRecord(newRecord)
                completedTrackers.insert(tracker.id)
            }

            try trackerStore.trackerRecordStore.saveContext()
            collectionView.reloadData()
        } catch {
            print("[TrackersViewController] Ошибка при изменении статуса выполнения трекера: \(error)")
        }
    }
    
    private func getCompletionCount(for tracker: Tracker) -> Int {
        do {
            let trackerRecords = try trackerStore.trackerRecordStore.fetchAllTrackerRecords()
            let completionDates = Set(trackerRecords.filter { $0.id == tracker.id }.map { $0.date })
            return completionDates.count
        } catch {
            print("[TrackersViewController] Ошибка при подсчете выполненных дней: \(error)")
            return 0
        }
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
    
    // MARK: - Core Data
    private func loadCategories() {
        let categoryStore = TrackerCategoryStore()
        
        do {
            let coreDataCategories = try categoryStore.fetchAllCategories()
            self.categories = coreDataCategories.map { categoryStore.convertToTrackerCategory(from: $0) }
            self.collectionView.reloadData()
        } catch {
            print("Ошибка при загрузке категорий: \(error)")
        }
    }
    
    private func addTracker(_ tracker: Tracker, to category: String) {
        do {
            let updatedCategory: TrackerCategory
            if let index = categories.firstIndex(where: { $0.title == category }) {
                var updatedTrackers = categories[index].trackers
                updatedTrackers.append(tracker)
                updatedCategory = TrackerCategory(title: categories[index].title, trackers: updatedTrackers)
                categories[index] = updatedCategory
                
                try categoryStore.updateCategory(categoryStore.fetchAllCategories()[index], with: updatedCategory)
            } else {
                updatedCategory = TrackerCategory(title: category, trackers: [tracker])
                categories.append(updatedCategory)
                
                try categoryStore.addCategory(updatedCategory)
            }

            try trackerStore.addNewTracker(tracker)

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }

        } catch {
            print("[TrackersViewController] Ошибка при добавлении трекера: \(error)")
        }
    }

    // MARK: - Deleting and editing a tracker
    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        do {
            if let trackerCoreData = try trackerStore.fetchTracker(by: tracker.id) {
                try trackerStore.deleteTracker(trackerCoreData)
            } else {
                print("Ошибка: Не удалось найти трекер в базе данных для удаления")
            }
        } catch { return }

        guard let categoryIndex = categories.firstIndex(where: { $0.title == filteredCategories[indexPath.section].title }) else { return }

        var updatedTrackers = categories[categoryIndex].trackers

        guard indexPath.item < updatedTrackers.count else { return }

        updatedTrackers.remove(at: indexPath.item)

        if updatedTrackers.isEmpty {
            categories.remove(at: categoryIndex)
        } else {
            let updatedCategory = TrackerCategory(title: categories[categoryIndex].title, trackers: updatedTrackers)
            categories[categoryIndex] = updatedCategory
        }
        
        collectionView.reloadData()
    }
    
    private func pinTracker(_ tracker: Tracker) {
        // Здесь будет логика закрепления трекера
        print("Закрепление трекера: \(tracker.name)")
    }

    private func showEditTrackerDialog(for tracker: Tracker) {
        // Здесь будет логика для редактирования трекера
        print("Редактирование трекера: \(tracker.name)")
    }

    private func confirmDeleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Удалить трекер?", message: "Эта операция необратима.", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.deleteTracker(tracker, at: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
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
        return filteredCategories[section].trackers.filter{ tracker in
            if tracker.schedule.isEmpty {
                return Calendar.current.isDate(currentDate, inSameDayAs: Date())
            } else {
                return tracker.schedule.contains(weekdayMapping[selectedDayOfWeek]!)
            }
        }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.reuseIdentifier, for: indexPath) as! TrackerCell
        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]

        cell.onPin = { [weak self] in
            self?.pinTracker(tracker)
        }

        cell.onEdit = { [weak self] in
            self?.showEditTrackerDialog(for: tracker)
        }

        cell.onDelete = { [weak self] in
            self?.confirmDeleteTracker(tracker, at: indexPath)
        }
        
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }

        let tracker = filteredCategories[indexPath.section].trackers[indexPath.item]
        
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.showEditTrackerDialog(for: tracker)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.confirmDeleteTracker(tracker, at: indexPath)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }

        return config
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
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupUI() {
        setupNavBar()

        [placeholderImage, labelImage, datePicker, collectionView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)

        
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        contentViewHeightConstraint.priority = .defaultLow
        
        
        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            labelImage.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            labelImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            contentViewHeightConstraint
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
