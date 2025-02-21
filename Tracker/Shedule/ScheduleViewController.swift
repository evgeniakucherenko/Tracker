import UIKit

final class ScheduleViewController: ThemedViewController {

    // MARK: - Properties
    weak var scheduleDelegate: ScheduleViewControllerDelegate?
    var viewModel: ScheduleViewModel

    //MARK: - UI Elements
    private let tableView = UITableView()

    private lazy var doneButton: CustomButton = {
        let doneButton = NSLocalizedString("done", comment: "Готово")
        let button = CustomButton(title: doneButton)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializer
    init(viewModel: ScheduleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
        viewModel.onDaysUpdated?(viewModel.selectedDays)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateTheme() {
        super.updateTheme()
        view.backgroundColor = ColorPalette.backgroundColor
    }

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupViews()
        setupConstraints()
        setupTableView()
        bindViewModel()
        updateTheme()
    }

    // MARK: - Setup Methods
    private func setupNavBar() {
        let schedule = NSLocalizedString("schedule", comment: "Расписание")
        _ = TitlePopup(title: schedule, navigationItem: navigationItem)
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

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.onDaysUpdated = { [weak self] selectedDays in
            self?.tableView.reloadData()
            self?.doneButton.isEnabled = !selectedDays.isEmpty
        }
    }
    
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        scheduleDelegate?.didSelect(days: viewModel.selectedDays)
        dismiss(animated: true, completion: nil)
    }
}
