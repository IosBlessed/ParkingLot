//
//  ParkingLotCoordinator.swift
//  ParkingLot
//
//  Created by Никита Данилович on 05.07.2023.
//

import Foundation
import UIKit

final class ParkingLotCoordinator: ParkingLotCoordinatorProtocol {
    unowned var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func openParkingLotListScreen() {
        let viewController = ParkingLotListBuilder.build() as! ParkingLotListViewController
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func openCreateParkingLotScreen() {
        let viewController = CreateParkingLotBuilder.build() as! CreateParkingLotViewController
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func openEditParkingLotScreen(parkingLot: ParkingLot? = nil, fromCreate: Bool = false) {
        let viewController = EditParkingLotBuilder.build(parkingLot: parkingLot) as! EditParkingLotViewController
        viewController.coordinator = self
        viewController.fromCreate = fromCreate
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func regularUserWantsToScanLot() {
        
    }
    
    func configureSettingsScreen() {
        let viewController = SettingsBuilder.build() as! SettingsViewController
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }
}
