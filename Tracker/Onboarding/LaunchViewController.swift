//
//  LaunchViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 27.08.2024.
//

import Foundation
import UIKit

final class LaunchViewController: UIViewController {
    
    //MARK: - Lifycylce
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blueYP
        setupConstraints()
    }
    
    //MARK: - UI Elements
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .logo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Setup Methods
    private func setupConstraints() {
        view.addSubview(logoImage)
        
        NSLayoutConstraint.activate([
            logoImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
}
