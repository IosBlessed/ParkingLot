//
//  CreateAccountBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович  on 14.06.2023.
//

import Foundation

class CreateAccountBuilder {
    static func build() -> CreateAccountViewControllerProtocol {
        let view = CreateAccountViewController()
        let viewModel = CreateAccountViewModel()
        let viewService = CreateAccountService()
        viewModel.service = viewService
        view.viewModel = viewModel
        return view
    }
}
