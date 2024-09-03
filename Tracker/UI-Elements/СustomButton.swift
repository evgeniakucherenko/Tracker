//
//  СustomButton.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
    // MARK: - Initializers
    init(title: String) {
        super.init(frame: .zero)
        configureButton(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureButton(title: String) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        self.titleLabel?.textAlignment = .center
        self.backgroundColor = .blackYP
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 16
    }
    
    // MARK: - Update Methods
    func update(title: String? = nil, backgroundColor: UIColor? = nil) {
        if let title = title {
            self.setTitle(title, for: .normal)
        }
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
    }
}
