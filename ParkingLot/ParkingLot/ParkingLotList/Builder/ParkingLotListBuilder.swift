//
//  ParkingLotListBuilder.swift
//  ParkingLot
//
//  Created by Никита Данилович on 05.07.2023.
//

import Foundation

class ParkingLotListBuilder {
    static func build() -> ParkingLotListViewControllerProtocol {
        let view = ParkingLotListViewController()
        let viewModel = ParkingLotListViewModel()
        let service = ParkingLotListService()
        viewModel.service = service
        view.viewModel = viewModel
        return view
    }
}
