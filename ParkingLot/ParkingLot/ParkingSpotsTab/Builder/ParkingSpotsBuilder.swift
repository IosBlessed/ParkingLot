//
//  ParkingSpotsBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович on 16.07.2023.
//

import Foundation

class ParkingSpotsBuilder {
    static func build(parkingLot: ParkingLot) -> ParkingSpotsViewController {
        let view = ParkingSpotsViewController()
        let viewModel = ParkingSpotsViewModel()
        let viewService = ParkingSpotsService()
        viewModel.service = viewService
        viewModel._parkingLot = parkingLot
        view.viewModel = viewModel
        return view
    }
}
