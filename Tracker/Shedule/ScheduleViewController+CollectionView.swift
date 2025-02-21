import UIKit

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

        cell.configure(with: weekday, isSelected: viewModel.selectedDays.contains(weekday), isFirst: isFirst, isLast: isLast)

        cell.onSwitchToggled = { [weak self] isOn in
            self?.viewModel.toggleDay(weekday)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 75 }
}

