//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 30.08.2024.
//

import Foundation
import UIKit

class ScheduleCell: UITableViewCell {
    
    // MARK: - Public Properties
    static let reuseIdentifier = "ScheduleCell"
    var onSwitchToggled: ((Bool) -> Void)?
    
    // MARK: - UI Elements
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .blackYP
        return label
    }()
    
    let switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .blueYP
        switchControl.thumbTintColor = .white
            switchControl.tintColor = .lightGrayYP
        switchControl.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGrayYP
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    func configure(with day: Weekday, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        dayLabel.text = day.rawValue
        switchControl.isOn = isSelected
        
        containerView.layer.cornerRadius = isFirst || isLast ? 16 : 0
        containerView.layer.maskedCorners = []

        if isFirst {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if isLast {
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        } else {
            separatorView.isHidden = false
        }
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        contentView.addSubview(containerView)
        contentView.addSubview(separatorView)
        containerView.addSubview(dayLabel)
        containerView.addSubview(switchControl)
        
        [containerView,dayLabel,
         switchControl,separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dayLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                
            switchControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // MARK: - Actions
    @objc private func switchToggled(_ sender: UISwitch) {
        onSwitchToggled?(sender.isOn)
    }
}


