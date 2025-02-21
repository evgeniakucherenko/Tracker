//
//  File.swift
//  Tracker
//
//  Created by Evgenia Kucherenko on 09.10.2024.
//

import Foundation
import UIKit

protocol Authenticatable {
    func login(email: String, password: String)
    func logout()
}

protocol ProfileUpdatable {
    func updateProfile(newName: String, newEmail: String)
    func updateAvatar(newAvatarURL: String)
}

class Authentication: Authenticatable {
    var name: String
    var email: String
    
    init(name: String, email: String) {
        self.name = name
        self.email = email
    }
    
    func login(email: String, password: String) {}
    
    func logout() {}
        
}

class UserProfile: Authentication {
    var avatarURL: String
    
    init(name: String, email: String, avatarURL: String) {
        self.avatarURL = avatarURL
        super.init(name: name, email: email)
    }
    
    func viewProfile() -> String {
        return "Name: \(name), Email: \(email)"
    }
    
}

extension UserProfile: ProfileUpdatable {
    
    func updateProfile(newName: String, newEmail: String) {
        self.name = newName
        self.email = newEmail
    }

    func updateAvatar(newAvatarURL: String) {
        self.avatarURL = newAvatarURL
    }
}



