import Foundation
import UIKit

final class CustomTabBarController: UITabBarController {

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background
        tabBar.isTranslucent = false

        addTopBorder(color: UIColor.gray, thickness: 0.5)
    }

    private func addTopBorder(color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: thickness)
        tabBar.layer.addSublayer(border)
    }
}
