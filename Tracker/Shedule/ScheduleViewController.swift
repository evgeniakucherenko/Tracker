import UIKit

final class ScheduleViewController: ThemedViewController {
    
    // MARK: - Properties
    weak var scheduleDelegate: ScheduleViewControllerDelegate?
    var viewModel: ScheduleViewModel

    // MARK: - UI Elements
    private let tableView = UITableView()

    private lazy var doneButton: CustomButton = {
        let doneButton = NSLocalizedString("done", comment: "Готово")
        let button = CustomButton(title: doneButton)
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Initializer
    init(viewModel: ScheduleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateTheme() {
        super.updateTheme()
        view.backgroundColor = ColorPalette.backgroundColor
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        setupViews()
        setupConstraints()
        setupTableView()
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

    // MARK: - Методы обновления UI, вызываемые Coordinator'ом
    func updateTableView() {
        self.tableView.reloadData()
    }

    func updateDoneButtonState(_ isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
    }

    // MARK: - Actions
    @objc private func doneButtonTapped() {
        scheduleDelegate?.didSelect(days: viewModel.selectedDays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfDays
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.reuseIdentifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }

        let weekday = viewModel.getDay(at: indexPath.row)
        let isSelected = viewModel.isDaySelected(at: indexPath.row)
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == viewModel.numberOfDays - 1

        cell.configure(with: weekday, isSelected: isSelected, isFirst: isFirst, isLast: isLast)

        cell.onSwitchToggled = { [weak self] _ in
            self?.viewModel.toggleDay(weekday)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

