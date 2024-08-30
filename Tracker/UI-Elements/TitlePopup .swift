//
//  TitlePopup .swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import Foundation
import UIKit

class TitlePopup: UIView {
    
    // MARK: - Properties
    private let label: UILabel
    
    // MARK: - Initializers
    init(title: String, navigationItem: UINavigationItem) {
        self.label = UILabel()
        super.init(frame: .zero)
        configureTitle(title: title)
        setupNavBar(with: navigationItem)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureTitle(title: String) {
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.text = title
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    // MARK: - Setup Methods
    private func setupNavBar(with navigationItem: UINavigationItem) {
        navigationItem.titleView = self
    }
}
