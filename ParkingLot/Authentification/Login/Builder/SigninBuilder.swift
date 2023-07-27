//
//  SigninBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович  on 14.06.2023.
//

import Foundation

class SignInBuilder {
    static func build() -> SignInViewControllerProtocol {
        let view = SignInViewController()
        let viewModel = SignInViewModel()
        let service = SignInService()
        viewModel.service = service
        view.viewModel = viewModel
        return view
    }
}
