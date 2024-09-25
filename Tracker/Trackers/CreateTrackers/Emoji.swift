//
//  Emoji.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 07.09.2024.
//

import Foundation
import UIKit

class EmojiCollectionView: UIView {
    
    // MARK: - Properties
    var emojiData: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙏", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    var onEmojiSelected: ((String) -> Void)?
    private var selectedIndexPath: IndexPath?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EmojiCell")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        return collectionView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupConstraints()
    }
       
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupConstraints()
    }
    
    // MARK: - Setup Method
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension EmojiCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let emojiLabel = UILabel()
        emojiLabel.text = emojiData[indexPath.item]
        emojiLabel.font = .systemFont(ofSize: 32)
        emojiLabel.textAlignment = .center
        
        cell.contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
     
        if selectedIndexPath == indexPath {
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.backgroundColor = .addGrayYP
        } else {
            cell.contentView.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath)
            
            let label = UILabel(frame: headerView.bounds)
            label.text = "Emoji"
            label.font = .boldSystemFont(ofSize: 19)
            label.textAlignment = .left
            label.textColor = .blackYP
            headerView.addSubview(label)
            
            return headerView
        }
        return UICollectionReusableView()
    }
}


extension EmojiCollectionView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmoji = emojiData[indexPath.item]
        onEmojiSelected?(selectedEmoji)
        
        let previousSelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        var indexPathsToReload = [indexPath]
        if let previous = previousSelectedIndexPath {
            indexPathsToReload.append(previous)
        }
        collectionView.reloadItems(at: indexPathsToReload)
    }
}
