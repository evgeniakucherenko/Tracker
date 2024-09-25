//
//  Weekday.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 17.09.2024.
//

import Foundation

extension Weekday {
    var shortName: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}
