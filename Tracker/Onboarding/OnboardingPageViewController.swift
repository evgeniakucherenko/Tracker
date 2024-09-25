//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 24.09.2024.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private let imageView = UIImageView()
    private let textLabel = UILabel()
    
    private lazy var finishButton: CustomButton = {
        let button = CustomButton(title: "Вот это технологии!")
        button.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var imageName: String?
    var text: String?
    
    init(imageName: String, text: String) {
        self.imageName = imageName
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc private func finishButtonTapped() {
        if let onboardingVC = parent?.parent as? OnboardingViewController {
            onboardingVC.finishOnboarding()
        } else {
            print("Не удалось получить OnboardingViewController")
        }
    }
    
    private func setupUI() {

        if let imageName = imageName {
            backgroundImageView.image = UIImage(named: imageName)
        }
        
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        textLabel.text = text
        textLabel.textColor = .blackYP
        textLabel.font = .boldSystemFont(ofSize: 32)
        textLabel.numberOfLines = 2
        textLabel.textAlignment = .center
        
        [textLabel, finishButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -270),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}


