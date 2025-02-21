import UIKit

protocol TrackersFilteringControllerDelegate: AnyObject {
    func didSelectFilter(at index: Int)
}

final class TrackersFilteringController: ThemedViewController {
    
    weak var delegate: TrackersFilteringControllerDelegate?
    
    private let filters: [String] = [
        "Все трекеры",
        "Трекеры на сегодня",
        "Завершенные",
        "Не завершенные"
    ]

    private var selectedFilterIndex: Int? = 1
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.reuseIdentifier)
        tableView.isHidden = true
        return tableView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupViews()
        setupConstraints()
        tableView.isHidden = false
    }
    
    // MARK: - Setup Methods
    private func setupNavBar() {
        let category = NSLocalizedString("filters", comment: "")
        _ = TitlePopup(title: category, navigationItem: navigationItem)
    }
    
    private func setupViews() {
        [tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TrackersFilteringController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.reuseIdentifier, for: indexPath) as! FilterCell
        let isSelected = indexPath.row == selectedFilterIndex
        cell.configure(
            with: filters[indexPath.row],
            isSelected: isSelected,
            isFirst: indexPath.row == 0,
            isLast: indexPath.row == filters.count - 1,
            isSingleItem: filters.count == 1
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectFilter(at: indexPath.row)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8 // Отступ между секциями
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}




