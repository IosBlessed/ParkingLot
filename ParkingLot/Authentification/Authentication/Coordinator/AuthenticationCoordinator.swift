//
//  AuthenticationCoordinator.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.06.2023.
//

import Foundation
import UIKit

final class AuthentificationCoordinator: AuthentificationCoordinatorProtocol {
    unowned var navigationController: UINavigationController
    var coordinator: MainCoordinatorProtocol!
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func initialSetup() {
        let viewController = AuthenticationBuilder.build() as! AuthenticationViewController
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func openCreateAccScreen() {
        let viewController = CreateAccountBuilder.build() as! CreateAccountViewController
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func openSignInScreen() {
        let viewController = SignInBuilder.build() as! SignInViewController
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func moveToForgotPasswordScreen() {
        let viewController = ForgotPasswordBuilder.build()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func authenticationDidFinish() {
        coordinator.initializeParkingLot()
    }
}
