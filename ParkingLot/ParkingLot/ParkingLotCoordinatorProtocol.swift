//
//  ParkingLotCoordinatorProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 05.07.2023.
//

import Foundation

protocol ParkingLotCoordinatorProtocol: AnyObject {
    func openCreateParkingLotScreen()
    func openParkingLotListScreen()
    func openEditParkingLotScreen(parkingLot: ParkingLot?, fromCreate: Bool)
    func regularUserWantsToScanLot()
    func configureSettingsScreen()
}
