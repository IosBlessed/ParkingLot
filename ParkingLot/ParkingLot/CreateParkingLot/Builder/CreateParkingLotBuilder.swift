//
//  CreateParkingLotBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович on 03.07.2023.
//

import Foundation

final class CreateParkingLotBuilder {
    static func build(parkingLot: ParkingLot? = nil) -> CreateParkingLotViewControllerProtocol {
        let view = CreateParkingLotViewController()
        view.parkingLot = parkingLot
        let viewModel = CreateNewParkingLotViewModel()
        view.viewModel = viewModel
        let service = CreateParkingLotService()
        viewModel.service = service
        return view
    }
}
