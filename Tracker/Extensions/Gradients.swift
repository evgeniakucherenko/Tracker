import UIKit

extension UIView {
    func addGradientBorder(colors: [UIColor], lineWidth: CGFloat, cornerRadius: CGFloat) {

        layer.sublayers?.removeAll(where: { $0.name == "gradientBorder" })

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = bounds.insetBy(dx: -lineWidth, dy: -lineWidth)
        gradientLayer.name = "gradientBorder"
        gradientLayer.cornerRadius = cornerRadius + lineWidth / 2

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer

        layer.addSublayer(gradientLayer)
    }
}
