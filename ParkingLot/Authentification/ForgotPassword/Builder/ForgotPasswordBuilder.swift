//
//  ForgotPasswordBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович on 30.06.2023.
//

import Foundation

struct ForgotPasswordBuilder {
    static func build() -> ForgotPasswordViewController {
        let viewController = ForgotPasswordViewController()
        let viewModel = ForgotPasswordViewModel()
        let service = ForgotPasswordService()
        viewModel.service = service
        viewController.viewModel = viewModel
        return viewController
    }
}
