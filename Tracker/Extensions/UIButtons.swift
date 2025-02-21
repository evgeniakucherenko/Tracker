import UIKit
//
//extension UIButton {
//    private func image(withColor color: UIColor) -> UIImage? {
//        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
//        UIGraphicsBeginImageContext(rect.size)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        context.setFillColor(color.cgColor)
//        context.fill(rect)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//
//    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
//        setBackgroundImage(image(withColor: color), for: state)
//    }
//}
