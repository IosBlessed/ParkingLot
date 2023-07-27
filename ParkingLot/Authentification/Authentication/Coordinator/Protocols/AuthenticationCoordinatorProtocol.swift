//
//  AuthenticationCoordinatorProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович  on 14.06.2023.
//

import Foundation
import UIKit

protocol AuthentificationCoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController { get set }
    var coordinator: MainCoordinatorProtocol! { get set }
    func initialSetup()
    func openCreateAccScreen()
    func openSignInScreen()
    func moveToForgotPasswordScreen()
    func authenticationDidFinish()
}
