//
//  EditParkingLotBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович on 07.07.2023.
//

import Foundation

import Foundation

final class EditParkingLotBuilder {
    static func build(parkingLot: ParkingLot? = nil) -> EditParkingLotViewControllerProtocol {
        let view = EditParkingLotViewController()
        let viewModel = EditParkingLotViewModel()
        let service = EditParkingLotService()
        viewModel.service = service
        view.viewModel = viewModel
        view.parkingLot = parkingLot
        return view
    }
}
