//
//  Tracker.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 29.08.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
}

enum Weekday: String, CaseIterable, Codable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}

