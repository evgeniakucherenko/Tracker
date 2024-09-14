//
//  TrackerCell.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 01.09.2024.
//

import Foundation
import UIKit

final class TrackerCell: UICollectionViewCell, UIContextMenuInteractionDelegate {
    
    // MARK: - Public Properties
    static let reuseIdentifier = "TrackerCell"
    var onCompletionToggle: (() -> Void)?
    var onDelete: (() -> Void)?
    var onPin: (() -> Void)?
    var onEdit: (() -> Void)?
    
    // MARK: - UI-elements
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        label.textColor = .blackYP
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .whiteYP
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cardImageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true

        let interaction = UIContextMenuInteraction(delegate: self)
        view.addInteraction(interaction)
        
        return view
    }()
    
    lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        view.layer.cornerRadius = 12
        return view
    }()

    let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .blackYP
        return label
    }()
    
    private lazy var plusButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = UIImage(systemName: "plus", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .selection14
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cardQuantityManagementView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
    }

    // MARK: - Context Menu Interaction Delegate
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in

            let pinAction = UIAction(title: "Закрепить") { _ in
                self.onPin?()
            }
            
            let editAction = UIAction(title: "Редактировать") { _ in
                self.onEdit?()
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                self.onDelete?()
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }

    // MARK: - Configure Cell
    func configure(with title: String, days: Int, category: String, emoji: String, color: UIColor, isRepeatedCategory: Bool, isCompleted: Bool) {
        titleLabel.text = title
        daysLabel.text = "\(days) \(pluralizeDay(days))"
        emojiLabel.text = emoji
        cardImageView.backgroundColor = color
        plusButton.backgroundColor = color
        categoryLabel.text = category
        categoryLabel.isHidden = false
        categoryLabel.textColor = isRepeatedCategory ? .white : .black
        
        let borderColor = UIColor(named: "gray_color_YP")?.withAlphaComponent(0.3)
        cardImageView.layer.borderColor = borderColor?.cgColor
        cardImageView.layer.borderWidth = 1.0
        
        updateButtonAppearance(isCompleted: isCompleted)
    }

    private func pluralizeDay(_ count: Int) -> String {
        switch count % 10 {
        case 1 where count % 100 != 11:
            return "день"
        case 2, 3, 4 where (count % 100 < 10 || count % 100 >= 20):
            return "дня"
        default:
            return "дней"
        }
    }
    
    private func updateButtonAppearance(isCompleted: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = UIImage(systemName: isCompleted ? "checkmark" : "plus", withConfiguration: config)
        plusButton.setImage(image, for: .normal)
        plusButton.alpha = isCompleted ? 0.3 : 1.0
        plusButton.isEnabled = !isCompleted
    }

    // MARK: - Actions
    @objc private func plusButtonTapped() {
        if !plusButton.isEnabled {
            return
        }
        onCompletionToggle?()
    }
}

// MARK: - Setup UI
extension TrackerCell {
    
    private func setupViews() {
        self.addSubview(categoryLabel)
        
        [titleLabel,emojiBackgroundView, emojiLabel].forEach {
            cardImageView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [cardImageView, plusButton, daysLabel, cardQuantityManagementView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
    
            categoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            cardImageView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            cardImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cardImageView.heightAnchor.constraint(equalToConstant: 90),
            
            cardQuantityManagementView.heightAnchor.constraint(equalToConstant: 58),
            cardQuantityManagementView.topAnchor.constraint(equalTo: cardImageView.bottomAnchor),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: cardImageView.topAnchor, constant: 10),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardImageView.leadingAnchor, constant: 10),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
                    
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardImageView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardImageView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: -12),
            
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            plusButton.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 8),
            
            daysLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            daysLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -10)
        ])
    }
}
