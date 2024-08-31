//
//  CategoryCell.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 31.08.2024.
//

import Foundation
import UIKit

class CategoryCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryCell"
    
    // MARK: - UI Elements
    private let customTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        textField.backgroundColor = .clear
        return textField
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupConstraints()
        configureAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupConstraints() {
        contentView.addSubview(customTextField)
        
        NSLayoutConstraint.activate([
            customTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            customTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
    
    private func configureAppearance() {
        backgroundColor = UIColor(named: "light_gray_YP")
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }
    
    // MARK: - Configuration
    func configure(with category: String, isSelected: Bool, isFirst: Bool, isLast: Bool) {
        customTextField.text = category
        
        if isSelected {
                    accessoryView = UIImageView(image: UIImage(named: "check_icon"))
                } else {
                    accessoryView = nil
                }
        
        contentView.layer.cornerRadius = (isFirst || isLast) ? 16 : 0
        contentView.layer.maskedCorners = []
        
        if isFirst {
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if isLast {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        if isFirst && isLast {
            separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}
