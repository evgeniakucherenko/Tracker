import Foundation
import UIKit

protocol LaunchViewControllerDelegate: AnyObject {
    func didFinishLaunching()
}

final class LaunchViewController: UIViewController {
    
    weak var delegate: LaunchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blueYP
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.delegate?.didFinishLaunching()
        }
        
        UserDefaults.standard.set(false, forKey: "onboardingCompleted")
    }
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .logo
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func setupConstraints() {
        view.addSubview(logoImage)
        
        NSLayoutConstraint.activate([
            logoImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        ])
    }
}
