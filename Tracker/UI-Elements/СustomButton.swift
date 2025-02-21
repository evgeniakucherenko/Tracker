import UIKit

class CustomButton: UIButton {
    
    // MARK: - Initializers
    init(title: String) {
        super.init(frame: .zero)
        configureButton(title: title)
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration
    private func configureButton(title: String) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        self.titleLabel?.textAlignment = .center
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
    }
    
    // MARK: - Appearance Updates
    private func updateAppearance() {
        if self.isEnabled {
            self.backgroundColor = UIColor(named: "buttonEnabledColor")
            self.setTitleColor(UIColor(named: "buttonEnabledTitleColor"), for: .normal)
        } else {
            self.backgroundColor = UIColor(named: "buttonDisabledColor")
            self.setTitleColor(UIColor(named: "buttonDisabledTitleColor"), for: .normal)
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }
}
