import UIKit

final class StatCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let reuseIdentifier = "StatCell"
    
    // MARK: - UI Elements
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0
        view.layer.borderColor = UIColor.systemGray4.cgColor
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardView.layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })

        DispatchQueue.main.async {
            self.cardView.addGradientBorder(
                colors: [UIColor(hex: "#007BFA"), UIColor(hex: "#46E69D"), UIColor(hex: "#FD4C49")],
                lineWidth: 1,
                cornerRadius: self.cardView.layer.cornerRadius
            )
        }
    }
    
    // MARK: - Configuration
    func configure(with stat: StatItem) {
        valueLabel.text = stat.value
        titleLabel.text = stat.description
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(cardView)
        [valueLabel, titleLabel].forEach { cardView.addSubview($0) }
    }
    
    private func setupConstraints() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
}
