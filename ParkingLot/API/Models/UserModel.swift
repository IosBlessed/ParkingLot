//
//  UserModel.swift
//  ParkingLot
//
//  Created by Никита Данилович on 11.07.2023.
//

import Foundation

struct UserCreate: Codable {
    let name: String
    let email: String
    let password: String
    let phone: String
}

struct User: Codable {
    let email: String
    let role: String
    let jwt: String
}

struct UserAuthenticate: Codable {
    let email: String
    let password: String
}

enum UserRole: String {
    case admin = "ADMIN"
    case regular = "REGULAR"
}

enum UserDefaultsKeys: String {
    case token = "token"
    case role = "role"
}

struct GlobalUser {
    static var jwt: String? = nil
    static var role: String? = nil
}
