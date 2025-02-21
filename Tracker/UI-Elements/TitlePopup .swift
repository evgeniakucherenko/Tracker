import UIKit

class TitlePopup: UIView {
    private let label: UILabel
    
    // MARK: - Initializers
    init(title: String, navigationItem: UINavigationItem) {
        self.label = UILabel()
        super.init(frame: .zero)
        configureTitle(title: title)
        setupNavBar(with: navigationItem)
        updateTheme()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureTitle(title: String) {
        label.font = .systemFont(ofSize: 16, weight: .medium)
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
    
    // MARK: - Theme Updates
    @objc private func updateTheme() {
        label.textColor = UIColor(named: "textColor")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
            
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                updateTheme()
        }
    }
}
