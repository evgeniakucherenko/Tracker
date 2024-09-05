//
//  CustomSelectionButton.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 30.08.2024.
//

import Foundation
import UIKit

class CustomSelectionButton: UIButton {
    
    // MARK: - Properties
    private let customTitleLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    // MARK: - Initializers
    init(title: String) {
        super.init(frame: .zero)
        configureButton(title: title)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func configureButton(title: String) {
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor(named: "light_gray_YP")
            
        customTitleLabel.text = title
        customTitleLabel.textColor = .blackYP
        customTitleLabel.font = UIFont.systemFont(ofSize: 17)
        customTitleLabel.numberOfLines = 2
        customTitleLabel.textAlignment = .left
            
        arrowImageView.image = UIImage(resource: .backIcon)
        arrowImageView.tintColor = .grayColorYP
            
        self.addSubview(customTitleLabel)
        self.addSubview(arrowImageView)
    }
    
    // MARK: - Layout
    private func setupConstraints() {
        
        [customTitleLabel, arrowImageView, self].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
           
        NSLayoutConstraint.activate([
            customTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            customTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            customTitleLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
               
            arrowImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }

    // MARK: - Update Method
    func update(title: String, subtitle: String? = nil) {
        if let subtitle = subtitle, !subtitle.isEmpty {
            let combinedText = "\(title)\n\(subtitle)"
            let attributedText = NSMutableAttributedString(string: combinedText)
            
            let titleRange = NSRange(location: 0, length: title.count)
            let subtitleRange = NSRange(location: title.count + 1, length: subtitle.count)
            
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: titleRange)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: subtitleRange)
            attributedText.addAttribute(.foregroundColor, value: UIColor.blackYP, range: titleRange)
            attributedText.addAttribute(.foregroundColor, value: UIColor.grayColorYP, range: subtitleRange)
            
            customTitleLabel.attributedText = attributedText
        } else {
            customTitleLabel.text = title
        }
    }
}
