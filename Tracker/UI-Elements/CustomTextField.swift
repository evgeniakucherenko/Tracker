import Foundation
import UIKit

class CustomTextField: UITextField {
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextField()
    }
    
    // MARK: - Setup Methods
    private func setupTextField() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
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
        
        self.textColor = .text
        self.font = UIFont.systemFont(ofSize: 16)
        self.clearButtonMode = .whileEditing 
    }
    
    // MARK: - Theme Updates
    @objc private func updateTheme() {
        self.backgroundColor = UIColor(named: "customSelectionButtonColor")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
            
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateTheme()
        }
    }
}
