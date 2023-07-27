//
//  MainCoordinatorProtocol.swift
//  ParkingLot
//
//  Created by Никита Данилович on 13.06.2023.
//

import UIKit

protocol MainCoordinatorProtocol: AnyObject {
    var navigationController: UINavigationController! { get set }
    func initializeAuthentification()
    func initializeParkingLot()
}
