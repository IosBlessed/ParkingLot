//
//  AuthenticationBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.06.2023.
//

import Foundation

struct AuthenticationBuilder {
    static func build() -> AuthenticationViewControllerProtocol {
        let viewController = AuthenticationViewController()
        return viewController
    }
}
