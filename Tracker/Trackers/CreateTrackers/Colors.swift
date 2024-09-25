//
//  Colors.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 07.09.2024.
//

import Foundation
import UIKit

class ColorsCollectionView: UIView {
    
    // MARK: - Properties
    var colorData: [UIColor] = [.selection1, .selection2, .selection3, .selection4, .selection5, .selection6, .selection7, .selection8, .selection9, .selection10, .selection11, .selection12, .selection13, .selection14, .selection15, .selection16, .selection17, .selection18]
    
    var onColorSelected: ((UIColor) -> Void)?
    private var selectedIndexPath: IndexPath?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
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

extension ColorsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection  section: Int) -> Int {
        return colorData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let colorView = UIView(frame: CGRect(x: 6, y: 6, width: 40, height: 40))
        colorView.backgroundColor = colorData[indexPath.item]
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        cell.contentView.addSubview(colorView)

        if indexPath == selectedIndexPath {
            let selectedColor = colorData[indexPath.item].withAlphaComponent(0.3)
            cell.layer.borderWidth = 3.0
            cell.layer.borderColor = selectedColor.cgColor
            cell.layer.cornerRadius = 8
            cell.layer.masksToBounds = true
        } else {
            cell.layer.borderWidth = 0
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedColor = colorData[indexPath.item]
        onColorSelected?(selectedColor) 
        
        let previousSelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        
        var indexPathsToReload = [indexPath]
        if let previous = previousSelectedIndexPath {
            indexPathsToReload.append(previous)
        }
        collectionView.reloadItems(at: indexPathsToReload)
    }
       
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "HeaderView", for: indexPath)
                
                let label = UILabel(frame: headerView.bounds)
                label.text = "Цвет"
                label.font = .boldSystemFont(ofSize: 19)
                label.textAlignment = .left
                label.textColor = .blackYP
                headerView.addSubview(label)
                
                return headerView
            }
        
        return UICollectionReusableView()
    }
}

extension ColorsCollectionView: UICollectionViewDelegateFlowLayout &  UICollectionViewDelegate {

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
}

