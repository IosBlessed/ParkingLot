//
//  MainCoordinator.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.06.2023.
//

import UIKit
import Foundation

final class MainCoordinator: MainCoordinatorProtocol {
    
    var navigationController: UINavigationController!
    
    func initializeAuthentification() {
        let authentificationCoordinator = AuthentificationCoordinator(
            navigationController: self.navigationController
        )
        authentificationCoordinator.coordinator = self
        authentificationCoordinator.initialSetup()
    }
    
    func initializeParkingLot() {
        let parkingLotCoordinator = ParkingLotCoordinator(navigationController: self.navigationController)
        parkingLotCoordinator.openParkingLotListScreen()
    }
}
