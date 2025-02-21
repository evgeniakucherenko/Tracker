import UIKit

class CustomActionButton: UIButton {
    
    // MARK: - Initializer
    init(title: String,
         backgroundColor: UIColor,
         titleColor: UIColor = .white,
         borderColor: UIColor? = nil,
         borderWidth: CGFloat = 0,
         cornerRadius: CGFloat = 16,
         action: Selector,
         target: Any?) {
        super.init(frame: .zero)
        configureButton(
            title: title,
            backgroundColor: backgroundColor,
            titleColor: titleColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            cornerRadius: cornerRadius
        )
        addTarget(target, action: action, for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    private func configureButton(
        title: String,
        backgroundColor: UIColor,
        titleColor: UIColor,
        borderColor: UIColor?,
        borderWidth: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let borderColor = borderColor {
            self.layer.borderColor = borderColor.cgColor
            self.layer.borderWidth = borderWidth
        }
    }
    
    // MARK: - State Update
    func setEnabled(_ isEnabled: Bool, enabledColor: UIColor = .systemBlue, disabledColor: UIColor = .gray) {
        self.isEnabled = isEnabled
        self.backgroundColor = isEnabled ? enabledColor : disabledColor
    }
}
