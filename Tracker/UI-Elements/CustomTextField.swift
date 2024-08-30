//
//  CustomTextField.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import Foundation
import UIKit

class CustomTextField: UITextField {
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupTextField() {
        
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        
        self.backgroundColor = UIColor(named: "light_gray_YP")
                
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.leftViewMode = .always
                
        self.attributedPlaceholder = NSAttributedString(
            string: "Введите название трекера",
            attributes: [
                .foregroundColor: UIColor(named: "gray_color_YP") ?? UIColor.lightGray,
                .font: UIFont.systemFont(ofSize: 16)
            ]
        )
        
        self.textColor = .blackYP
        self.font = UIFont.systemFont(ofSize: 16)
    }
    
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
           
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 60),
            self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40)
        ])
    }
}
