//
//  test.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 26.09.2024.
//

import Foundation
import UIKit

//struct UserData {
//    let username: String
//    var password: String
//    var role: String
//}
//
//// Хранилище информации о пользователях.
////Реализует паттерн "Синглтон" для обеспечения единого экземпляра в приложении
//class UserRepository {
//    static let shared = UserRepository()
//    // Статическое свойство класса, которое хранит единственный экземпляр UserRepository. Паттерн "Синглтон" гарантирует, что во всем приложении будет использоваться один и тот же экземпляр класса.Доступ к этому экземпляру осуществляется через UserRepository.shared. Единая точка доступа: Все компоненты приложения обращаются к одному и тому же экземпляру UserRepository, что обеспечивает согласованность данных.
//
//    private var users: [String: UserData] = [:]
//    // Приватное свойство, представляющее собой словарь, где ключом является username (строка), а значением — объект UserData.
//    
//    private init() {}
//    // Приватный инициализатор предотвращает создание новых экземпляров класса извне.
//    // Это важный аспект реализации синглтона, так как он ограничивает создание объекта только внутри класса.
//        
//    // Добавление пользователя. Добавляет пару username: UserData в словарь users. Если пользователь с таким именем уже существует, его данные будут перезаписаны.
//        func addUser(_ user: UserData) {
//            users[user.username] = user
//        }
//        
//    // Получение пользователя. Возвращает данные пользователя по его имени. Позволяет другим классам получить доступ к информации о пользователе для различных операций, таких как аутентификация.
//        func getUser(username: String) -> UserData? {
//            return users[username]
//        }
//        
//    // Обновление пользователя. Перезаписывает данные пользователя в словаре users.
//        func updateUser(_ user: UserData) {
//            users[user.username] = user
//        }
//}
//
//class UserAuthenticationService {
//    
//    private var attempts: [String: Int] = [:]
//    private var lastAttemptTime: [String: Date] = [:]
//    private let lockoutTime: TimeInterval = 600
//    private let userRepository = UserRepository.shared
//    let logger = LogMessenger()
//    
//    // Метод для аутентификации пользователя
//    func authenticate(username: String, password: String) -> Bool {
//        if let lastAttempt = lastAttemptTime[username],
//           let attempts = attempts[username],
//           attempts >= 3,
//           Date().timeIntervalSince(lastAttempt) <= lockoutTime {
//           print("Account is locked out. Try again later.")
//            return false
//        }
//
//        if let user = userRepository.getUser(username: username), user.password == password  {
//            logger.log(message: "Authentication successful.")
//            attempts[username] = 0
//            return true
//        } else {
//            print("Authentication failed.")
//            let newAttemptCount = (attempts[username] ?? 0) + 1
//            attempts[username] = newAttemptCount
//            lastAttemptTime[username] = Date()
//            return false
//        }
//    }
//}
//
//class RegistrationManager {
//    
//    let notificationService = NotificationService()
//    private let userRepository = UserRepository.shared
//
//    // Метод для регистрации пользователя
//    func register(username: String, password: String, role: String = "User") {
//        guard userRepository.getUser(username: username) == nil else {
//            print("Username already exists.")
//            return
//        }
//        let newUser = UserData(username: username, password: password, role: role)
//        userRepository.addUser(newUser)
//        notificationService.sendEmail(username)
//    }
//}
//
//
//class NotificationService {
//    
//    func sendEmail(_ username: String) {
//        print("Sending email to \(username)...")
//        // ... (код для отправки email)
//    }
//    
//    func sendSMS(_ username: String) {
//        print("Sending SMS to \(username)...")
//        // ... (код для отправки SMS)
//    }
//}
//
//class PasswordManager {
//    
//    let notificationService = NotificationService()
//    let logger = LogMessenger()
//    private let userRepository = UserRepository.shared
//    
//    
//    // Метод для сброса пароля
//    func resetPassword(username: String, newPassword: String) {
//        guard var user = userRepository.getUser(username: username) else {
//            print("User does not exist.")
//            return
//        }
//        user.password = newPassword
//        userRepository.updateUser(user)
//        logger.log(message: "Password reset successful.")
//       
//        notificationService.sendSMS(username)
//    }
//    
//}
//
//class LogMessenger {
//    // Метод для вывода информационных сообщений
//    func log(message: String) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "y-MM-dd H:m:ss"
//        print("\(dateFormatter.string(from: Date())): \(message)")
//        
//        // использование
////        let logger = LogMessenger()
////        logger.log(message: "Your message here")
//    }
//}
//
//class UserManager {
//    private let userRepository = UserRepository.shared
//    
//    func getUserRole(username: String) -> String? {
//        return userRepository.getUser(username: username)?.role
//    }
//}


class ButtonUI {
    func setup(for button: UIButton) {
        button.backgroundColor = .blue
    }
}

class SwitchUI {
    func setup(for switch: UISwitch) {
        switch.onTintColor = .g
    }
}
