//
//  SigninViewControllerProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович  on 14.06.2023.
//

import Foundation

protocol SignInViewControllerProtocol: AnyObject {
    var coordinator: AuthentificationCoordinatorProtocol! { get set }
    var viewModel: SignInViewModelProtocol! { get set }
    func userDoesNotExistsInTheSystem()
}
