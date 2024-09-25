//
//  LaunchViewController.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 27.08.2024.
//

import Foundation
import UIKit

final class LaunchViewController: UIViewController {
    
    //MARK: - Lifycycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blueYP
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showNextScreen()
        }
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
    
    // MARK: - Navigation
    private func showNextScreen() {

        let onboardingCompleted = UserDefaults.standard.bool(forKey: "onboardingCompleted")
            
        if onboardingCompleted {
            let mainViewController = TabBarController()
            setRootViewController(mainViewController)
        } else {
            let onboardingViewController = OnboardingViewController()
            setRootViewController(onboardingViewController)
        }
    }
        
    private func setRootViewController(_ viewController: UIViewController) {

        if let window = UIApplication.shared.windows.first {
            window.rootViewController = viewController
            UIView.transition(with: window, 
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: nil,
                              completion: nil)
        } else {
            print("Не удалось получить window")
        }
    }
}
