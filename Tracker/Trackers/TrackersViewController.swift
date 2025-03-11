
import UIKit
import Foundation

final class TrackersViewController: UIViewController, CreateTrackerControllerDelegate {

    var viewModel: TrackersViewModel
    var alertPresenter: AlertPresenter!
    weak var coordinator: TrackersCoordinator?

    // MARK: - UI Elements
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let placeholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "placeholder_image")
        imageView.isHidden = true
        return imageView
    }()
    
    let labelImage: UILabel = {
        let label = UILabel()
        let emptyTrackers = NSLocalizedString("emptyTrackers", comment: "")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.text = emptyTrackers
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        return DatePickerConfigurator.createDatePicker(
            locale: Locale(identifier: "ru_RU"),
            mode: .date,
            style: .automatic,
            cornerRadius: 8
        )
    }()
    
    private lazy var filterButton: CustomActionButton = {
    let button = CustomActionButton(
        title: NSLocalizedString("filters", comment: ""),
        backgroundColor: UIColor(named: "blue_YP") ?? .gray,
        action: #selector(filterButtonTapped),
        target: self
    )
        
    return button
    }()

    // MARK: - Initializer
    init(viewModel: TrackersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        collectionView.delegate = self

        setupNavBar()
        setupUI()
        setupBindings()
        updateTheme()
        
        Task {
            await viewModel.loadInitialData()
        }
        alertPresenter = AlertPresenter(viewController: self)
    
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        }

    // MARK: - Setup Methods
    private func setupBindings() {
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                let isContentAvailable = !(self?.viewModel.filteredCategories.isEmpty ?? true)
                self?.updateScrollViewState(isContentAvailable: isContentAvailable)
            }
        }

        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Ошибка", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func setupUI() {
        [placeholderImage, labelImage, collectionView, filterButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)

        NSLayoutConstraint.activate([
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            labelImage.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 16),
            labelImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNavBar() {
        let trackersTitle = NSLocalizedString("trackers", comment: "NavBar Title")
        NavBarConfigurator.configureNavigationBar(
            for: self,
            title: trackersTitle,
            datePicker: datePicker,
            addButtonAction: #selector(addButtonTapped),
            searchResultsUpdater: self
        )
    }
    
    // MARK: - Theme Updates
    @objc private func updateTheme() {
        view.backgroundColor = ColorPalette.backgroundColor
        labelImage.textColor = ColorPalette.textColor
        datePicker.backgroundColor = ColorPalette.datePickerColor
        datePicker.layer.cornerRadius = 10
    }

    // MARK: - Actions
    @objc private func filterButtonTapped() {
        coordinator?.showFilterScreen(delegate: self)
    }
    
    @objc private func addButtonTapped() {
        coordinator?.showCreateTracker(delegate: self)
    }
    
    @objc private func dateChanged() {
        viewModel.updateDate(datePicker.date)
    }

    private func updateScrollViewState(isContentAvailable: Bool) {
        collectionView.isHidden = !isContentAvailable
        placeholderImage.isHidden = isContentAvailable
        labelImage.isHidden = isContentAvailable
    }
    
    func presentEditTrackerScreen(for tracker: Tracker) {
        coordinator?.showEditTrackerScreen(
            for: tracker,
            categoryStore: viewModel.categoryStore,
            trackerStore: viewModel.trackerStoreRef
        )
    }
}

// MARK: - CreateTrackerControllerDelegate & TrackersFilteringControllerDelegate 
extension TrackersViewController {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) async {
        await viewModel.addTracker(tracker, to: category)
    }

    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) async {
        await viewModel.addTracker(tracker, to: category)
    }
}

extension TrackersViewController: TrackersFilteringControllerDelegate {
    func didSelectFilter(at index: Int) {
        viewModel.applyFilter(at: index)
        collectionView.reloadData()
    }
}
