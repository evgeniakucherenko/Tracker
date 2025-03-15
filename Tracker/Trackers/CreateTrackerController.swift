import Foundation
import UIKit

final class CreateTrackerController: UIViewController {
    
    weak var delegate: CreateTrackerControllerDelegate?
    private var categoryStore: TrackerCategoryStoreProtocol

    weak var navigationDelegate: CreateTrackerControllerNavigationDelegate?
    
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

        setupNavBar()
        setupViews()
        setupConstraints()
        updateTheme()
    }
    
    // MARK: - UI Elements
    private lazy var habitButton: CustomButton = {
        let habitButton = NSLocalizedString("habitButton", comment: "")
        let button = CustomButton(title: habitButton)
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var irregularEventButton: CustomButton = {
        let irregularEventButton = NSLocalizedString("irregularEventButton", comment: "")
        let button = CustomButton(title: irregularEventButton)
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Theme Updates
    private func updateTheme() {
        view.backgroundColor = ColorPalette.backgroundColor
    }
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        let titlePopupCreateTracker = NSLocalizedString("titlePopupCreateTracker", comment: "")
        _ = TitlePopup(title: titlePopupCreateTracker, navigationItem: navigationItem)
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
        navigationDelegate?.startHabitsFlow()
    }
    
    @objc private func irregularEventButtonTapped() {
        navigationDelegate?.showIrregularEvent(delegate: self)
    }
}

// MARK: - Создание трекера/события
extension CreateTrackerController: CreateHabitsControllerDelegate & IrregularEventControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, inCategory category: String) async {
        print("✅ CreateTrackerController: didCreateTracker вызван")
        print("📌 Перед вызовом делегата: delegate = \(String(describing: delegate))")
        
        await delegate?.didCreateTracker(tracker, inCategory: category)
        dismiss(animated: true, completion: nil)
    }

    func didCreateIrregularEvent(_ tracker: Tracker, inCategory category: String) async {
        await delegate?.didCreateIrregularEvent(tracker, inCategory: category)
        dismiss(animated: true, completion: nil)
    }
}

