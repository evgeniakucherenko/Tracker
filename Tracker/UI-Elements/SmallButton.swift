import UIKit

final class SmallButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }
    
    // MARK: - Appearance Setup
    private func setupAppearance() {
        self.layer.cornerRadius = 16
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        self.titleLabel?.textAlignment = .center
        updateAppearance()
    }
    
    private func updateAppearance() {
        if self.isEnabled {
            self.backgroundColor = UIColor(named: "buttonSmallEnabledColor")
            self.setTitleColor(UIColor(named: "buttonSmallEnabledTextColor"), for: .normal)
        } else {
            self.backgroundColor = UIColor(named: "buttonSmallDisabledColor")
            self.setTitleColor(UIColor(named: "buttonSmallDisabledTextColor"), for: .normal)
        }
    }
    
    // Обновление при изменении состояния
    override var isEnabled: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    // Обновление при смене темы
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateAppearance()
        }
    }
}
