//
//  UIColor.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 10.09.2024.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var colorName: String? {
        for (name, color) in UIColor.colorMapping {

            if self.isEqualToColor(color) {
                return name
            }
        }
        return nil
    }
    
    var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)
        return String(format: "#%06x", rgb)
    }
    
    private static let colorMapping: [String: UIColor] = {
        var mapping = [String: UIColor]()
        for i in 1...16 {
            if let color = UIColor(named: "selection_\(i)") {
                mapping["selection_\(i)"] = color
            }
        }
        return mapping
    }()
    
    private func isEqualToColor(_ otherColor: UIColor) -> Bool {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0
        self.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        
        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0
        otherColor.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return red1 == red2 && green1 == green2 && blue1 == blue2 && alpha1 == alpha2
    }
}


